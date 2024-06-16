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
    ../common/optional/tailscale-exit-node.nix
    ../common/users/spencer.nix
    ./services
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
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [/persist/boot/ssh/ssh_host_ed25519_key];
          authorizedKeys = config.users.users.spencer.openssh.authorizedKeys.keys;
        };
        postCommands = ''
          # ensure pools are being imported
          zpool import -a
          # load key and kill pending password prompt on ssh
          echo "zfs load-key rpool/crypt; killall zfs" >> /root/.profile
        '';
      };
    };
  };

  hyperparabolic.base.zfs = {
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
