{
  flake.modules.nixos.hosts-warden = {...}: {
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
