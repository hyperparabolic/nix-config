{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/fingerprint.nix
    ../common/optional/hyprland.nix
    ../common/optional/laptop.nix
    ../common/optional/pipewire.nix
    ../common/optional/pipewire-raop.nix
    ../common/optional/steam.nix
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking = {
    # required for ZFS
    hostId = "15e99f7b";
    hostName = "magnolia";
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];
  };

  programs = {
    dconf.enable = true;
  };

  boot = {
    initrd.systemd.enable = true;
    kernelParams = [
      # no swap, disable hibernate
      "nohibernate"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  hyperparabolic = {
    impermanence = {
      enable = true;
      enableRollback = true;
    };
    zfs = {
      enable = true;
      autoSnapshot = false; # TODO: configure and enable later
      impermanenceRollbackSnapshot = "rpool/crypt/local/root@blank";
      zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
      zedMailCommand = "${pkgs.notify}/bin/notify";
      zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # firmware updates: `fwupdmgr update`
  services.fwupd.enable = true;

  programs.steam.gamescopeSession.args = [
    "--output-width 2256"
    "--output-height 1504"
    "--prefer-output eDP-1"
  ];

  # an older version is needed specifically for downgrading the fingerprint sensor
  # all set up with fingers enrolled now, shouldn't be needed, but here for documentation
  # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd#getting-the-fingerprint-sensor-to-work
  # services.fwupd.package = (import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
  #   sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
  # }) {
  #   inherit (pkgs) system;
  # }).fwupd;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
