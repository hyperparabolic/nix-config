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
    ../common/optional/pipewire.nix
    ../common/users/spencer.nix
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking.hostName = "oak";
  hardware.system76.enableAll = true;

  # required for ZFS
  networking.hostId = "d86c4730";

  # I have no intent to ever try to hibernate this host for now (nvidia, bleh).
  # It also should never run out of RAM, but I still want swap for OS optimization.
  # zram (https://wiki.archlinux.org/title/Zram) creates a RAM block device with
  # zstd compression so the OS can still have swap for memory management purposes.
  zramSwap = {
    enable = true;
    # May grow up to 50% of RAM capacity if something insane is happening (increasing
    # capacity by the compression ratio), but doesn't start there.
    memoryPercent = 50;
  };

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
