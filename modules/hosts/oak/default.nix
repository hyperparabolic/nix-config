{
  flake.modules.nixos.hosts-oak = {inputs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.system76
    ];

    boot = {
      initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = ["kvm-amd"];
    };

    hardware.cpu.amd.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.05";
  };
}
