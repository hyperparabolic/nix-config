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
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/smokeping-prometheus-exporter.nix
    ../common/optional/tailscale-exit-node.nix
    ../common/users/spencer.nix
    ./services
  ];

  nixpkgs = {
    # host specific overlays
    overlays = [];
  };

  networking = {
    # required for ZFS
    hostId = "59a43ec6";
    hostName = "warden";
    nameservers = [
      "127.0.0.1"
    ];
  };

  programs = {
    dconf.enable = true;
  };

  boot = {
    kernelParams = [
      "nohibernate"
    ];
    kernelModules = ["igb"];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    # remote unlock via ssh
    initrd = {
      kernelModules = ["igb"];
      secrets = {
        "/persist/boot/ssh/ssh_host_ed25519_key" = "/persist/boot/ssh/ssh_host_ed25519_key";
      };
      systemd = {
        enable = true;
        network = {
          enable = true;
          networks.enp2s0 = {
            enable = true;
            name = "enp2s0";
            DHCP = "yes";
          };
        };
        services.zfs-remote-unlock = {
          description = "Prepare for ZFS remote unlock";
          wantedBy = ["initrd.target"];
          after = ["systemd-networkd.service"];
          path = with pkgs; [
            zfs
          ];
          serviceConfig.Type = "oneshot";
          script = ''
            echo "systemctl default" >> /var/empty/.profile
          '';
        };
      };
      network = {
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = ["/persist/boot/ssh/ssh_host_ed25519_key"];
          authorizedKeys = config.users.users.spencer.openssh.authorizedKeys.keys;
        };
      };
    };
  };

  hyperparabolic.zfs = {
    enable = true;
    autoSnapshot = false; # TODO: configure and enable later
    rollbackSnapshot = "rpool/crypt/local/root@blank";
    zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
    zedMailCommand = "${pkgs.notify}/bin/notify";
    zedMailCommandOptions = "-bulk -provider-config /run/secrets/notify-provider-config";
  };

  services.thermald.enable = true;

  # dbus-broker to share hardware with ha containers
  services.dbus.implementation = "broker";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
