{
  pkgs,
  lib,
  config,
  ...
}: let
  /*
  PCI devices specified in pciIds get stubbed with the vfio_pci driver,
  preventing linux from loading its drivers. This ensures they are "clean"
  when they get passed through to a VM and behave well there. This is
  mostly only necessary for GPUs.
  */
  pciIds = [
    # 3090 graphics
    "10de:2204"
    # 3090 audio
    "10de:1aef"
  ];
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
      # stub PCI devices
      ("vfio-pci.ids=" + lib.concatStringsSep "," pciIds)
    ];
  };

  # manipulates systemd slices to isolate host cpu from win11
  virtualisation.libvirtd.hooks.qemu = {
    cpu-isolate-win11 = ./cpu-isolate-win11.sh;
  };

  # setup for pipewire user session sharing with qemu-libvirtd
  #
  # I really like sharing pipewire directly with vms when I need native-like audio
  # performance and behavior. It behaves just like a native device on host and guest
  # simultaneously. However, my setup has a few quirks that I'm not willing to compromise
  # on that makes this tricky:
  #
  # - I run libvirt vms as a non-root user
  # - I run pipewire as a user service (system level service is an option, but it isn't
  # the intended use case and seems best effort support)
  #
  # libvirt also requires that the pipewire runtime directory is owned by the qemu user
  # if that user isn't root, so a bind mount is being used to create a duplicate of the
  # pipewire socket that does not need read permissions for the original socket.
  #
  # System level services can't have a dependency on user session services, so this requires
  # some creativity below.
  systemd = {
    services = {
      prepare-run-qemu-libvirtd = {
        description = "Create run directory for qemu-libvirtd";
        wantedBy = ["libvirtd.service"];
        after = ["libvirtd.service"];
        script = ''
          mkdir -p /run/libvirt/qemu/pipewire
          chown -R qemu-libvirtd:qemu-libvirtd /run/libvirt/qemu/pipewire
          chmod 770 /run/libvirt/qemu/pipewire
        '';
        serviceConfig = {
          RemainAfterExit = "yes";
        };
      };
      wait-pipewire = {
        description = "Wait for spencer user pipewire socket";
        wantedBy = ["user@1000.service"];
        after = ["user@1000.service"];
        serviceConfig = {
          TimeoutStartSec = "infinity";
          # ConditionPathExists can't test the socket directly, since you're expected
          # to put a dependency on pipewire.socket instead. That lives in the user
          # session though so that dependency can't work. This works fine.
          ConditionPathExists = "/run/user/1000/pipewire-0.lock";
          RemainAfterExit = "yes";
          ExecStart = "${lib.getExe' pkgs.coreutils "sleep"} 1000";
        };
      };
    };
    mounts = [
      {
        description = "Share pipewire user socket with libvirtd via bind mount";
        what = "/run/user/1000/pipewire-0";
        where = "/run/libvirt/qemu/pipewire/pipewire-0";
        type = "none";
        options = "bind,rw";
        wantedBy = ["user@1000.service"];
        wants = [
          "wait-pipewire.service"
          "prepare-run-qemu-libvirtd.service"
        ];
        after = [
          "prepare-run-qemu-libvirtd.service"
          "user@1000.service"
          "wait-pipewire.service"
        ];
      }
    ];
  };
}
