{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.impermanence.nixosModules.impermanence
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

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  # opt-in persistence - disabled for bootstrapping
  environment.persistence = {
    "/persist" = {
      directories = [
        "/etc/nixos"
	"/etc/shadow"
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
        "/srv"
      ];
    };
  };

  programs = {
    git.enable = true;
    neovim.enable = true;
  };

  users.users = {
    spencer = {
      # replace on startup
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuxIDOWjjLv2g/Pnr0/V+NtlvFfGadJq5Cxsb06lQ1X spencer@sloth"
      ];
      extraGroups = ["wheel"];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
