#!/usr/bin/env bash

# ensure pipewire sinks are created and linked
./pw-setup.sh

# configure VM options
OPTS=""

# Basic CPU settings, kvm=off is vm spoofing for nvidia
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp 16,sockets=1,cores=16,threads=1"
# Enable KVM full virtualization support.
OPTS="$OPTS -enable-kvm"
# Assign memory to the vm.
OPTS="$OPTS -m 16000"

# Supply OVMF (general UEFI bios, needed for EFI boot support with GPT disks).
OPTS="$OPTS -drive if=pflash,format=raw,readonly=on,file=/run/libvirt/nix-ovmf/OVMF_CODE.fd"
OPTS="$OPTS -drive if=pflash,format=raw,file=$(pwd)/OVMF_VARS.fd"

# pass through zvol as virtio device (this requires drivers iso at install time!)
# OS drive
OPTS="$OPTS -drive file=/dev/zvol/rpool/crypt/virt/win10,index=0,format=raw,if=virtio"

# VFIO GPU and GPU sound passthrough.
OPTS="$OPTS -device vfio-pci,host=21:00.0,multifunction=on"
OPTS="$OPTS -device vfio-pci,host=21:00.1"

# audio routing
OPTS="$OPTS -audiodev pipewire,id=snd1,in.name=win10-in,out.name=win10-out"
OPTS="$OPTS -device intel-hda -device hda-duplex,audiodev=snd1"

# evdev mouse and keyboard passthrough
# left + right ctrl to swap between host and guest control.
OPTS="$OPTS -device virtio-mouse,id=mouse1"
OPTS="$OPTS -device virtio-keyboard,id=kbd1"
OPTS="$OPTS -object input-linux,id=mouse1,evdev=/dev/input/by-id/usb-Wings_Tech_Xtrfy_M4-event-mouse"
OPTS="$OPTS -object input-linux,id=kbd1,evdev=/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd,grab_all=on,repeat=on"

# Installation disk
# OPTS="$OPTS -drive file=$(pwd)/Win10_22H2_English_x64v1.iso,index=2,media=cdrom"
# virtio drivers
# OPTS="$OPTS -drive file=$(pwd)/virtio-win-0.1.240.iso,index=3,media=cdrom"
# Use the following emulated video device (use :none for disabled).

# QXL output, if debugging in host is needed.
# OPTS="$OPTS -vga qxl"

# Using hardware video output, disable display
OPTS="$OPTS -display none"


# Redirect QEMU's console input and output.
OPTS="$OPTS -monitor stdio"

sudo -Hu qemu_user bash -c "qemu-system-x86_64 $OPTS"

