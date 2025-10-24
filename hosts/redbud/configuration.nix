{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/secureboot.nix
    ../common/users/spencer.nix
    ./services
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking = {
    # required for ZFS
    hostId = "55fbb629";
    hostName = "redbud";
    nameservers = [
      "192.168.1.1"
    ];
  };

  boot = {
    initrd.systemd.enable = true;
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
      autoSnapshot = true;
      impermanenceRollbackSnapshot = "rpool/crypt/local/root@blank";
      luksOnZfs = {
        enable = true;
        backingDevices = ["dev-nvme0n1p2.device"];
      };
      zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
      zedMailCommand = "${pkgs.notify}/bin/notify";
      zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
    };
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
