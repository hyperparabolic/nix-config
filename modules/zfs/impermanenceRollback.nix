{
  flake.modules.nixos.zfs = {
    config,
    lib,
    pkgs,
    ...
  }: let
    impermanenceRollbackSnapshot = "rpool/crypt/local/root@blank";
    enableImpermanenceRollback = config.this.impermanence.enableRollback;
  in {
    # rollback root fs to blank snapshot
    boot.initrd.systemd = lib.mkIf enableImpermanenceRollback {
      enable = lib.mkForce true;
      services.zfs-rollback = {
        description = "Rollback ZFS root dataset to blank snapshot";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "zfs-import-rpool.service"
        ];
        before = [
          "sysroot.mount"
        ];
        path = with pkgs; [
          zfs
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r ${impermanenceRollbackSnapshot} && echo "zfs rollback complete"
        '';
      };
    };
  };
}
