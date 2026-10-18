{
  flake.modules.nixos.hosts-pando1 = {inputs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];

    boot = {
      initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
      kernelModules = ["kvm-intel"];
    };

    this.secureboot.enable = false;

    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    system.stateVersion = "23.05";
  };
}
