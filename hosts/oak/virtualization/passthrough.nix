{
  pkgs,
  lib,
  config,
  ...
}: let
in {
  environment.systemPackages = with pkgs; [
    pciutils # pci querying tooling
    usbutils # usb querying tooling
    (
      pkgs.writeShellApplication {
        name = "virt-usb-hotplug";
        runtimeInputs = with pkgs; [libvirt];
        text = builtins.readFile ./virt-usb-hotplug.sh;
      }
    )
  ];

  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelParams = [
      "amd_iommu=on"
      "video=efifb:off"
      "video=vesafb:off"
      "quiet"
    ];
  };

  virtualisation.libvirtd.hooks.qemu = {
    # manipulates systemd slices to isolate host cpu from win10
    "cpu-isolate-win10" = lib.getExe (
      pkgs.writeShellApplication {
        name = "cpu-isolate-win10-qemu-hook";
        runtimeInputs = with pkgs; [systemd];
        text = builtins.readFile ./cpu-isolate-win10.sh;
      }
    );

    # single GPU passthrough. manages kernel modules and stops host display-manager
    "gpu-passthrough-win10" = lib.getExe (
      pkgs.writeShellApplication {
        name = "gpu-passthrough-win10-qemu-hook";
        runtimeInputs = with pkgs; [
          kmod
          libvirt
          systemd
        ];
        text = builtins.readFile ./gpu-passthrough-win10.sh;
      }
    );
  };

  # share pipewire socket with qemu-libvirtd via bind mount
  fileSystems."/srv/win10/pipewire-0" = {
    device = "/run/user/1000/pipewire-0";
    depends = [
      # mounting this fails absolutely without root fs, still needs socket from service
      "/"
    ];
    fsType = "none";
    options = [
      "bind"
      "rw"
      # any user may mount this
      "user"
      # do not mount automatically
      "noauto"
    ];
  };
}
