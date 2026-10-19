{
  flake.modules.nixos.hosts-pando2 = {...}: {
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/9825-D6FF";
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
