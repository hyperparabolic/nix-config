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
    inputs.nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/hyprland.nix
    ../common/optional/pipewire.nix
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking.hostName = "redbud";

  # required for ZFS
  networking.hostId = "55fbb629";

  programs = {
    dconf.enable = true;
  };

  boot = {
    kernelParams = [
      # no swap, disable hibernate
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
    rollbackSnapshot = "rpool/local/root@blank";
    zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
    zedMailCommand = "${pkgs.notify}/bin/notify";
    zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # laptop specific stuff, move somewhere common when I get another laptop
  # power management
  services.upower.enable = true;
  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
  ];

  # persist wifi connections
  environment.persistence = {
    "/persist".directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
