{
  flake.modules.nixos.hosts-warden = {inputs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    boot = {
      initrd.availableKernelModules = ["ahci" "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
      kernelModules = ["kvm-intel"];
    };

    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";
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
  };
}
