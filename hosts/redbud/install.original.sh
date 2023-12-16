#!/usr/bin/env bash

# based on:
# https://gist.github.com/mx00s/ea2462a3fe6fdaa65692fe7ee824de3e?permalink_comment_id=3325146
# with modifications for zfs on LUKS and other tweaks.
#
# Other resources:
# https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS.html
# https://grahamc.com/blog/erase-your-darlings/
#
# `sudo ./install.sh /dev/disk/by-id/...`

set -euo pipefail

# log helpers
export COLOR_RESET="\033[0m"
export RED_BG="\033[41m"
export BLUE_BG="\033[44m"

function err {
    echo -e "${RED_BG}$1${COLOR_RESET}"
}

function info {
    echo -e "${BLUE_BG}$1${COLOR_RESET}"
}

# parse and validate args
# ROOT_DISK must be a block device by id or label for
# consistent zfs imports when mirroring is introduced later
export ROOT_DISK=$1

if ! [[ -b "$ROOT_DISK" ]]; then
    err "Invalid argument: '${DISK_PATH}' is not a block special file"
    exit 1
fi

if [[ "$EUID" > 0 ]]; then
    err "Must run as root"
    exit 1
fi

export ZFS_POOL="rpool"

# ephemeral datasets, still want these encrypted as they are cleared
# on boot, not shutdown.
export ZFS_LOCAL="${ZFS_POOL}/local"
export ZFS_DS_ROOT="${ZFS_LOCAL}/root"
export ZFS_DS_NIX="${ZFS_LOCAL}/nix"

# persistent datasets
export ZFS_SAFE="${ZFS_POOL}/safe"
export ZFS_DS_PERSIST="${ZFS_SAFE}/persist"

export ZFS_BLANK_SNAPSHOT="${ZFS_DS_ROOT}@blank"

export MNT=$(mktemp -d)

# Installation start

info "Partitioning disks..."
# ensure disks have no pre-existing partitions
blkdiscard -f "$ROOT_DISK"

# slight overkill on boot size, but low maintenance during regular kernel changes
parted --script "$ROOT_DISK" -- \
mklabel gpt \
mkpart ESP fat32 1MiB 5GiB \
mkpart cryptroot 5GiB -17GiB \
set 1 esp on
partprobe "$ROOT_DISK"

export DISK_PART_BOOT="${ROOT_DISK}-part1"

info "Formatting boot partition ..."
mkfs.fat -F 32 -n boot "$DISK_PART_BOOT"

echo "Creating the encrypted partition, follow the instructions and use a strong password!"
cryptsetup luksFormat /dev/disk/by-partlabel/cryptroot

# mount the cryptdisk at /dev/mapper/nixroot
cryptsetup luksOpen /dev/disk/by-partlabel/cryptroot nixroot

info "Creating '$ZFS_POOL' ZFS pool for '/dev/mapper/nixroot' ..."
# some of these args are the default, setting them just in case
# or for posterity
zpool create -f \
  -o ashift=12 \
  -R "$MNT" \
  -O acltype=posixacl \
  -O xattr=sa \
  -O canmount=off \
  -O compression=lz4 \
  -O dnodesize=auto \
  -O relatime=on \
  -O dedup=off \
  -O mountpoint=/ \
  "$ZFS_POOL" \
  "/dev/mapper/nixroot"

info "Creating '$ZFS_DS_ROOT' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_ROOT"

info "Creating '$ZFS_BLANK_SNAPSHOT' ZFS snapshot ..."
zfs snapshot "$ZFS_BLANK_SNAPSHOT"

info "Mounting '$ZFS_DS_ROOT' to '$MNT' ..."
mount -t zfs "$ZFS_DS_ROOT" "$MNT"

info "Mounting '$DISK_PART_BOOT' to '$MNT'/boot ..."
mkdir "$MNT"/boot
mount -t vfat "$DISK_PART_BOOT" "$MNT"/boot

info "Creating '$ZFS_DS_NIX' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_NIX"

info "Mounting '$ZFS_DS_NIX' to '$MNT'/nix ..."
mkdir "$MNT"/nix
mount -t zfs "$ZFS_DS_NIX" "$MNT"/nix

info "Creating '$ZFS_DS_PERSIST' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_PERSIST"

info "Mounting '$ZFS_DS_PERSIST' to '$MNT'/persist ..."
mkdir "$MNT"/persist
mount -t zfs "$ZFS_DS_PERSIST" "$MNT"/persist

info "Creating persistent directory for host SSH keys ..."
mkdir -p "$MNT"/persist/etc/ssh

info "Generating NixOS configuration ('$MNT'/etc/nixos/*.nix) ..."
nixos-generate-config --root "$MNT"

# enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

info "System is not yet installed, reconcile hardware config, then"
info "nixos-install --root $MNT --no-root-passwd --flake .#host"
info "and then zpool export"
