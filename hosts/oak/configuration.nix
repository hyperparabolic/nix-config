{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.system76
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_6_12;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
