{
  flake.modules.nixos.hosts-magnolia = {...}: {
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
