{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  services = {
    # retired laptop server
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      IdleAction = "ignore";
    };
  };

  system.autoUpgradeHydra = {
    # canary system, update early and automatically reboot
    dates = "*-*-* 00:00:00 America/Chicago";
    settings = {
      reboot = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
