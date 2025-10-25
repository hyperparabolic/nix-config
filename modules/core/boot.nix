{
  flake.modules.nixos.core = {...}: {
    boot = {
      initrd.systemd.enable = true;
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };
    };
  };
}
