#!/usr/bin/env bash
set -x

guest=$1
command=$2

if [ "$guest" != "win10" ]; then
  echo "gpu-passthrough-win10.sh ignoring other guest"
  exit 0
fi

if [ "$command" = "prepare" ]; then
  echo "gpu-passthrough-win10.sh preparing GPU passthrough"
  systemctl stop display-manager

  # unbind VTConsoles, maybe not necessary? Debug this later
  echo 0 > /sys/class/vtconsole/vtcon0/bind
  echo 0 > /sys/class/vtconsole/vtcon1/bind

  # unbind EFI Framebuffer
  # echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

  sleep 2

  # unload gpu kernel modules
  modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia

  # detach GPU and HDMI audio devices from host
  virsh nodedev-detach pci_0000_21_00_0
  virsh nodedev-detach pci_0000_21_00_1

  # load vfio kernel module
  modprobe vfio-pci
elif [ "$command" = "release" ]; then
  echo "gpu-passthrough-win10.sh restore host GPU"

  # reattach GPU and HDMI audio devices to host
  virsh nodedev-reattach pci_0000_21_00_0
  virsh nodedev-reattach pci_0000_21_00_1

  # unload vfio kernel module
  modprobe -r vfio-pci

  # rebind EFI framebuffer
  # echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

  # load nvidia kernel modules
  modprobe nvidia_drm
  modprobe nvidia_modeset
  modprobe nvidia_uvm
  modprobe nvidia

  # bind VTConsoles, maybe not necessary? Debug this later
  echo 1 > /sys/class/vtconsole/vtcon0/bind
  echo 1 > /sys/class/vtconsole/vtcon1/bind

  systemctl start display-manager
fi
