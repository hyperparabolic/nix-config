{
  flake.modules.nixos.hosts-oak = {
    config,
    lib,
    pkgs,
    ...
  }: {
    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
      zfs = {
        backingDevices = [
          "dev-nvme0n1p1.device"
          "dev-nvme2n1p1.device"
        ];
      };
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/42D2-A7B0";
      fsType = "vfat";
      options = ["umask=0077"];
    };

    swapDevices = [
      {
        device = "/dev/disk/by-partuuid/2bd4266a-bbf5-48c3-a25c-483f576eeba7";
        randomEncryption.enable = true;
      }
    ];

    # there are some issues with non-legacymount datasets imported via boot.zfs.extraPools
    # mainly that pools imported this way mount all datasets including canmount=noauto
    # I don't want these mounted on boot, so this service mounts them instead
    systemd.services.zfs-mount-tank = {
      description = "import tank zfs pool and mount datasets";
      enable = true;
      # early enough in boot, sidesteps issues with hardware being unavailable
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecCondition = lib.getExe (
          # ensure pool is not already mounted
          pkgs.writeShellScriptBin "zfs-check-tank-mount" ''
            ! ${config.boot.zfs.package}/bin/zpool status | grep 'pool: tank$'
          ''
        );
        ExecStart = lib.getExe (
          pkgs.writeShellScriptBin "zfs-tank-mount" ''
            ${config.boot.zfs.package}/bin/zpool import tank
            ${config.boot.zfs.package}/bin/zfs mount -a
          ''
        );
      };
    };
  };
}
