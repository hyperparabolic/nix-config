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
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/gnome.nix
    ../common/optional/nvidia
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # Adds each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent.
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  networking.hostName = "oak";
  hardware.system76.enableAll = true;

  # required for ZFS
  networking.hostId = "d86c4730";

  boot = {
    # no swap, disable hibernate
    kernelParams = ["nohibernate"];
    supportedFilesystems = ["zfs"];
    zfs.forceImportRoot = false;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    # rollback root fs to blank snapshot
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/crypt/local/root@blank
    '';
  };

  # use latest kernel packages that are compatible with ZFS
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  # opt-in persistence
  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
        "/srv"
      ];
    };
  };
  programs.fuse.userAllowOther = true;

  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    # Keys are used here by sops-nix before impermanence can make
    # links. Must just use `/persist/` directory.
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      spencer = import ../../home/oak.nix;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
