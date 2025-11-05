{
  flake.modules.nixos.hosts-oak = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-hidpi
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.system76
    ];

    boot = {
      initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = ["kvm-amd"];
      kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
    };

    hardware.cpu.amd.updateMicrocode = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.05";

    this.monitors = [
      {
        name = "HDMI-A-1";
        width = 3840;
        height = 2160;
        x = 0;
        primary = true;
        workspaces = [
          "1"
          "2"
          "5"
          "6"
        ];
      }
      {
        name = "DVI-D-1";
        width = 1920;
        height = 1080;
        x = 3840;
        # vertical orientation
        transform = 3;
        workspaces = [
          "3"
          "4"
          "7"
          "8"
        ];
      }
    ];
  };
}
