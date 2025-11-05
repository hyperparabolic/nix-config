{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  services.thermald.enable = true;

  system.autoUpgradeHydra = {
    # backbone system, update late
    dates = "*-*-* 04:00:00 America/Chicago";
    settings = {
      reboot = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
