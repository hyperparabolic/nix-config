{
  pkgs,
  lib,
  config,
  ...
}: let
  pciIds = [
    # 3090 graphics
    "10de:2204"
    # 3090 audio
    "10de:1aef"
    # nvme drive
    "144d:a804"
  ];
in {
  /*
  PCI devices specified in pciIds get stubbed with the vfio_pci driver,
  preventing linux from loading its drivers. This ensures they are "clean"
  when they get passed through to a VM and behave well there. This is
  mostly only necessary for GPUs.
  */
  environment.systemPackages = with pkgs; [
    pciutils # pci querying tooling
    usbutils # usb querying tooling
    (
      pkgs.writeShellApplication {
        name = "virt-usb-hotplug";
        runtimeInputs = with pkgs; [libvirt];
        text = ''
          #!/usr/bin/env bash

          connection="qemu:///system"

          if [ $# -lt 3 ]; then
              echo "Usage: <domain> [ a | d ] [ [ # | <vendor_id>:<product_id> ] ... ]"
              exit 1
          fi
          
          domain="$1"
          shift 1

          case $1 in
              "attach" | "a")
                  action="attach-device"
                  ;;
              "detach" | "d")
                  action="detach-device"
                  ;;
              *)
                  echo "Usage: <domain> [ a | d ] [ [ # | <vendor_id>:<product_id> ] ... ]"
                  exit 1
          esac
          shift 1

          for o in "$@"; do
              case $o in
                  "1")
                      vendor_id="045e"
                      product_id="02ea"
                      ;;
                  *)
                      IFS=":" read -r vendor_id product_id <<< "$o"
                      ;;
              esac

              tmpfile=$(mktemp --suffix=.xml)
              echo "<hostdev mode=\"subsystem\" type=\"usb\" managed=\"yes\"><source><vendor id=\"0x$vendor_id\"/><product id=\"0x$product_id\"/></source></hostdev>" > "$tmpfile"
              echo "$tmpfile"
              echo "vendor_id=\"0x$vendor_id\""
              echo "product_id=\"0x$product_id\""

              virsh -c "$connection" "$action" "$domain" --file "$tmpfile" --persistent
          done
        '';
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

  # set up bridge so guests may have externally accessible ips
  networking.bridges = {
    "br0" = {
      interfaces = ["enp68s0"];
    };
  };

  networking.interfaces."br0".useDHCP = true;

  virtualisation.libvirtd.allowedBridges = ["br0"];

  # manipulates systemd slices to isolate host cpu from win10
  virtualisation.libvirtd.hooks.qemu = {
    cpu-isolate-win10 = ./cpu-isolate-win10.sh;
  };

  # persist /srv/win10, this directory is being used to store
  # resources required by the win10 vm that may not be granted by polkit
  # persisted because creation of this service may not be implemented in
  # a systemd user service.
  environment.persistence = {
    "/persist" = {
      directories = [
        "/srv/win10"
      ];
    };
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
