{
  flake.modules.nixos.hosts-oak = {pkgs, ...}: {
    services.postgresql = {
      # minimal config, currently only used by local services via socket
      # mostly zfs related tuning and moving data to tank zpool
      # ZFS specific tuning for datasets backing this:
      # - recordsize=16k - postgres blocks are 8k, this acts as an upper bound to help compression efficiency
      # - compression=l4z
      # - atime=off
      enable = true;
      package = pkgs.postgresql_17;
      dataDir = "/tank/postgres/17";
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
