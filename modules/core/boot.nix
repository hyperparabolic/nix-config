{
  flake.modules.nixos.core = {...}: {
    boot = {
      kernelParams = ["consoleblank=60"];
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };
    };
  };
}
