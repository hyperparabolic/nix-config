{
  flake.modules.nixos.hosts-redbud = {inputs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    boot = {
      initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
      kernelModules = ["kvm-intel"];
    };

    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";

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
  };
  flake.modules.homeManager.hosts-redbud = {...}: {
    # mcp client kiosk styling
    stylix.targets.gtk.enable = true;

    home.persistence."/persist".directories = [".local/state/wireplumber"];
  };
}
