{
  flake.modules.nixos.hosts-magnolia = {inputs, ...}: {
    imports = [
      # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ];

    boot = {
      initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = ["kvm-amd"];
    };

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = true;

    this.monitors = [
      {
        name = "eDP-1";
        width = 2256;
        height = 1504;
        primary = true;
        workspaces = [
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
        ];
      }
    ];

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    system.autoUpgradeHydra = {
      settings = {
        nix_build = {
          operation = "switch";
        };
      };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.05";
  };

  flake.modules.homeManager.hosts-magnolia = {pkgs, ...}: {
    home.persistence."/persist".directories = ["src"];

    # suspend after 6 minutes
    services.hypridle.settings.listener = [
      {
        timeout = 360;
        on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
