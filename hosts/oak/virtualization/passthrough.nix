{ pkgs, lib, config, ... }:
let
  pciIds = [
    # 3090 graphics
    "10de:2204"
    # 3090 audio
    "10de:1aef"
  ];
in
{
  /*
    PCI devices specified in pciIds get stubbed with the vfio_pci driver,
    preventing linux from loading its drivers. This ensures they are "clean"
    when they get passed through to a VM and behave well there. This is
    mostly only necessary for GPUs.
  */
  environment.systemPackages = with pkgs; [
    pciutils # pci querying tooling
    usbutils # usb querying tooling
  ];

  boot = {
    initrd.kernelModules =[
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelParams = [
      "amd_iommu=on"
      ("vfio-pci.ids=" + lib.concatStringsSep "," pciIds)
    ];
  };

  # usb hotplugging, not strictly related but I probably only want it here.
  virtualisation.spiceUSBRedirection.enable = true;
}
