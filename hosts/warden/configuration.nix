{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../common/global
    ../common/optional/notify.nix
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

  boot = {
    kernelModules = ["igb"];
    initrd = {
      kernelModules = ["igb"];
      systemd = {
        network = {
          enable = false;
          networks.enp2s0 = {
            enable = true;
            name = "enp2s0";
            DHCP = "yes";
          };
        };
      };
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
        backingDevices = ["dev-nvme0n1p1.device"];
      };
    };
  };

  services.thermald.enable = true;

  system.autoUpgradeHydra = {
    # backbone system, update late
    dates = "*-*-* 04:00:00 America/Chicago";
    settings = {
      reboot = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
