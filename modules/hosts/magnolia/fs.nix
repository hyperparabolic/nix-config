{
  flake.modules.nixos.hosts-magnolia = {...}: {
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/BF87-D3A9";
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
