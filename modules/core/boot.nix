{
  flake.modules.nixos.core = {...}: {
    boot = {
      initrd.systemd.enable = true;
      kernelParams = ["consoleblank=60"];
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };
    };
  };
}
