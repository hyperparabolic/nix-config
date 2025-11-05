{
  flake.modules.nixos.hosts-redbud = {...}: {
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/BEC7-664B";
      fsType = "vfat";
      options = ["umask=0077"];
    };

    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
      zfs = {
        backingDevices = [
          "dev-nvme0n1p2.device"
        ];
      };
    };
  };
}
