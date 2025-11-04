{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
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
