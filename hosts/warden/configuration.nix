{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../common/global
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking.hostName = "warden";

  # required for ZFS
  networking.hostId = "59a43ec6";

  programs = {
    dconf.enable = true;
  };

  boot = {
    kernelParams = [
      "nohibernate"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  hyperparabolic.base.zfs = {
    enable = true;
    autoSnapshot = false; # TODO: configure and enable later
    rollbackSnapshot = "rpool/crypt/local/root@blank";
    # zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
    # zedMailCommand = "${pkgs.notify}/bin/notify";
    # zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
  };

  services.thermald.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
