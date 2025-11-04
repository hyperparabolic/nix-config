{
  flake.modules.nixos.hosts-oak = {...}: {
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
  };
}
