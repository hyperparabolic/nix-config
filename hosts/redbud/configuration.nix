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
    ../common/optional/laptop.nix
    ../common/optional/pipewire.nix
    ../common/optional/pipewire-raop.nix
    ../common/users/spencer.nix
    ./services
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking.networkmanager.enable = true;
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

  # Remotely managed audio receiver, this is a bit hacky.
  # Audio devices are not initialized unless a local user is logged in.
  # These chagnes ensure a user is logged in on a lock screen.
  # Probably not very secure, but good enough for data that lives on this box
  services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session.command = "${lib.getExe' config.services.greetd.package "agreety"} --cmd $SHELL";
      # auto-login tty1 and run bash
      initial_session = {
        command = "${lib.getExe' pkgs.bashInteractive "bash"}";
        user = "spencer";
      };
    };
  };

  # but immediately lock bash sessions with vlock
  environment.systemPackages = [pkgs.vlock];
  programs.bash.shellInit = ''
    ${lib.getExe pkgs.vlock}
  '';

  services.pipewire = {
    wireplumber.extraConfig = {
      # using this machine as an audio receiver for airplay
      # ensure zero potential for loopback feedback by disabling internal devices
      "50-disable-internal-audio-device" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "device.name" = "alsa_card.pci-0000_00_1f.3";
              }
            ];
            actions = {
              update-props = {
                "device.disabled" = true;
              };
            };
          }
        ];
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
