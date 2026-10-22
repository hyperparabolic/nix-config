{
  flake.modules.nixos.hosts-oak = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # postgres upgrade scripts. docs:
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/databases/postgresql.md
    # run scripts with:
    # sudo -u postgres pg_upgrade_*
    pg_old = pkgs.postgresql_17.withPackages (ps: [
      # immich extensions
      ps.pgvector
      ps.vectorchord
    ]);
    pg_new = pkgs.postgresql_18.withPackages (ps: [
      # immich extensions
      ps.pgvector
      ps.vectorchord
    ]);
    pg_initdb = "${lib.getExe' pg_new "initdb"} -D /tank/postgres/${pg_new.psqlSchema} || exit 1";
    pg_upgrade = ''      ${lib.getExe' pg_new "pg_upgrade"} \
            --socketdir=/var/run/postgresql \
            --old-bindir=${pg_old}/bin \
            --new-bindir=${pg_new}/bin \
            --old-datadir=/tank/postgres/${pg_old.psqlSchema} \
            --new-datadir=/tank/postgres/${pg_new.psqlSchema} \
            --old-options "-c shared_preload_libraries='vchord.so'" \
            --new-options "-c shared_preload_libraries='vchord.so'"'';
    # may be run while the old version is active
    pg_upgrade_check = pkgs.writeShellScriptBin "pg_upgrade_check" ''
      cd /tank/postgres

      ${pg_initdb}

      ${pg_upgrade} \
      --check
    '';
    # - stop postgres.service
    # - prep run directory
    #   - mkdir /var/run/postgresql
    #   - chown postgres:postgres /var/run/postgresql
    # - run script
    # - update config version
    # - switch
    pg_upgrade_apply = pkgs.writeShellScriptBin "pg_upgrade_apply" ''
      cd /tank/postgres

      ${pg_initdb}

      ${pg_upgrade}
    '';
  in {
    environment.systemPackages = [
      pg_upgrade_check
      pg_upgrade_apply
    ];

    services.postgresql = {
      # minimal config, currently only used by local services via socket
      # mostly zfs related tuning and moving data to tank zpool
      # ZFS specific tuning for datasets backing this:
      # - recordsize=16k - postgres blocks are 8k, this acts as an upper bound to help compression efficiency
      # - compression=l4z
      # - atime=off
      enable = true;
      package = pkgs.postgresql_18;
      dataDir = "/tank/postgres/${config.services.postgresql.package.psqlSchema}";
      settings = {
        # zfs is copy on write, writes full pages for postgres
        full_page_writes = "off";
        # pre-initialized and reused files are not necessary or beneficial for copy on write
        wal_init_zero = "off";
        wal_recycle = "off";
      };
    };

    systemd.services.postgresql = {
      after = ["zfs-mount-tank.service"];
    };
  };
}
