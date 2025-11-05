{
  flake.modules.nixos.hosts-warden = {...}: {
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/A419-5A72";
      fsType = "vfat";
      options = ["umask=0077"];
    };

    swapDevices = [
      {
        device = "/dev/disk/by-partuuid/9186936a-6547-4506-8e49-74e40caebd04";
        randomEncryption.enable = true;
      }
    ];

    this = {
      impermanence = {
        enable = true;
        enableRollback = true;
      };
      zfs = {
        backingDevices = [
          "dev-nvme0n1p1.device"
        ];
      };
    };
  };
}
