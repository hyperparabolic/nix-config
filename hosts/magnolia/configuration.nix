{inputs, ...}: {
  imports = [
    # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
    ../common/optional/hyprland.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
