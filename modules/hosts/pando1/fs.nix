{
  flake.modules.nixos.hosts-pando1 = {...}: {
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/4BBE-B6C3";
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
