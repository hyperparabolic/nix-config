{
  flake.modules.nixos.nvidia = {lib, ...}: {
    # All in one module tweaked toward desktop use
    environment.variables = {
      NIXOS_OZONE_WL = 1;
    };

    hardware = {
      graphics.enable = true;
      nvidia = {
        open = lib.mkDefault true;
        modesetting.enable = true;
        nvidiaSettings = lib.mkDefault true;
        powerManagement.enable = true;
      };
    };

    # not actually using x11, but other packages in nixpkgs reference this
    services.xserver.videoDrivers = ["nvidia"];
  };
}
