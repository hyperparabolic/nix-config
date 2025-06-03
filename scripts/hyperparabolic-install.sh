# Installation script for nixos with LUKS on ZFS
#
# I wouldn't recommend using this if you find it. It's a higly
# opinionated install that won't really work outside this repo
# and its conventions.
#
# This is my v2 installation script, with the original drawing
# inspiration from these sources:
# https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS.html
# https://grahamc.com/blog/erase-your-darlings/
# https://gist.github.com/mx00s/ea2462a3fe6fdaa65692fe7ee824de3e

set -euo pipefail

# args and defaults
ARG_HOSTNAME=""
ARG_SSH_PRIVATE_KEY=""
ARG_NIX_CONFIG_DIR=""
ARG_BOOT_DISK=""
ARG_BOOT_PART_SIZE_GIB="5"
ARG_ROOT_DISK=""
ARG_ENABLE_SWAP=false
ARG_SWAP_SIZE_GIB=$(free -h | grep --color=auto "Mem" | awk -v col=2 '{print $col}' | sed 's/Gi//g')
ARG_NO_EXPORT=false
ARG_REBOOT=false
ARG_POWEROFF=false

# zfs names
ZFS_POOL_NAME="rpool"

# volume, LUKS encrypted secrets storage only mounted during boot
ZFS_VOLUMES="${ZFS_POOL_NAME}/volumes"
ZFS_VOL_SECRETS="${ZFS_VOLUMES}/bootsecrets"

# encrypted management dataset, keys stored in ZFS_KEY_ZVOL
ZFS_CRYPT="${ZFS_POOL_NAME}/crypt"

# local datasets, ephemeral or trivially reproduced
ZFS_LOCAL="${ZFS_CRYPT}/local"
ZFS_DS_ROOT="${ZFS_LOCAL}/root"
ZFS_SNAPSHOT_BLANK="${ZFS_DS_ROOT}@blank"
ZFS_DS_NIX="${ZFS_LOCAL}/nix"

# safe datasets, user data and persisted runtime data, autosnapshot and remote backups
ZFS_SAFE="${ZFS_CRYPT}/safe"
ZFS_DS_PERSIST="${ZFS_SAFE}/persist"

# ZFS_VOL_SECRETS partition / logical volume names
SECRETS_VOL="/dev/zvol/${ZFS_VOL_SECRETS}"
SECRETS_PART_LABEL=cryptroot
SECRETS_PART="/dev/disk/by-partlabel/${SECRETS_PART_LABEL}"
SECRETS_LVOL_LABEL=secretsroot
SECRETS_LVOL="/dev/mapper/${SECRETS_LVOL_LABEL}"

MNT=$(mktemp -d)

# logging
COLOR_RESET="\033[0m"
RED_BG="\033[41m"
BLUE_BG="\033[44m"

function err {
  echo -e "${RED_BG}$1${COLOR_RESET}"
}

function info {
  echo -e "${BLUE_BG}$1${COLOR_RESET}"
}

function ask_yn() {
  read -rp "$* [y/n]:" RESPONSE
  case $(echo "$RESPONSE" | tr '[:upper:]' '[:lower:]') in
    y|yes) return 0 ;;
    *)     return 1 ;;
  esac
}

function print_help() {
  printf "%b" "
Install nixos with LUKS on ZFS and hyperparabolic/nix-config conventions.

  $(basename "${BASH_SOURCE[0]}") [options]

Options:

    -h --help           Display this help message
    --hostname          Device hostname
    --ssh-key           Private ed25519 to be installed to this device (with corresponding .pub)
    --config            Directory containing flake to install
    --root-disk         Block device for root partition
    --boot-disk         Block device for optional separate boot / swap partition
    --boot-size         Boot partition size in GiB (default $ARG_BOOT_PART_SIZE_GIB)
    --swap              Enable swap
    --swap-size         Swap size in GiB (default $ARG_SWAP_SIZE_GIB)
    --no-export         Do not unmount fs or export zpool, leave for tweaks or debugging
    --reboot            Reboot after install
    --poweroff          Shut down after install
"
  exit 0
}

function partition_single_drive() {
  ROOT_PARTITION_INDEX_OFFSET=2
  ROOT_PARTITION_SIZE_OFFSET=$ARG_BOOT_PART_SIZE_GIB

  info "Partition single drive system"
  parted -a opt --script "$ARG_ROOT_DISK" -- mklabel gpt
  parted -a opt --script "$ARG_ROOT_DISK" -- mkpart ESP fat32 1MiB "${ARG_BOOT_PART_SIZE_GIB}GiB"
  parted -a opt --script "$ARG_ROOT_DISK" -- set 1 esp on
  DISK_PART_BOOT="${ARG_ROOT_DISK}-part1"
  info "Boot partition: ${DISK_PART_BOOT}"

  if [[ "$ARG_ENABLE_SWAP" = true ]]; then
    SWAP_END_OFFSET=$(( "$ARG_BOOT_PART_SIZE_GIB" + "$ARG_SWAP_SIZE_GIB" ))
    parted -a opt --script "$ARG_ROOT_DISK" -- mkpart swap linux-swap "${ARG_BOOT_PART_SIZE_GIB}GiB" "${SWAP_END_OFFSET}GiB"
    (( ROOT_PARTITION_INDEX_OFFSET++ ))
    ROOT_PARTITION_SIZE_OFFSET=$SWAP_END_OFFSET
    DISK_PART_SWAP="${ARG_ROOT_DISK}-part2"
    info "Swap partition: ${DISK_PART_SWAP}"
  fi

  parted -a opt --script "$ARG_ROOT_DISK" -- mkpart primary-1 "${ROOT_PARTITION_SIZE_OFFSET}GiB" 100%
  DISK_PART_ROOT="${ARG_ROOT_DISK}-part${ROOT_PARTITION_INDEX_OFFSET}"
  info "Root partition: ${DISK_PART_ROOT}"

  partprobe "$ARG_ROOT_DISK"
}

function partition_multi_drive() {
  info "Partition multi drive system"
  parted -a opt --script "$ARG_BOOT_DISK" -- mklabel gpt
  parted -a opt --script "$ARG_BOOT_DISK" -- mkpart ESP fat32 1MiB "${ARG_BOOT_PART_SIZE_GIB}GiB"
  parted -a opt --script "$ARG_BOOT_DISK" -- set 1 esp on
  DISK_PART_BOOT="${ARG_BOOT_DISK}-part1"
  info "Boot partition: ${DISK_PART_BOOT}"

  if [[ "$ARG_ENABLE_SWAP" = true ]]; then
    SWAP_END_OFFSET=$(( "$ARG_BOOT_PART_SIZE_GIB" + "$ARG_SWAP_SIZE_GIB" ))
    parted -a opt --script "$ARG_BOOT_DISK" -- mkpart swap linux-swap "${ARG_BOOT_PART_SIZE_GIB}GiB" "${SWAP_END_OFFSET}GiB"
    DISK_PART_SWAP="${ARG_BOOT_DISK}-part2"
    info "Swap partition: ${DISK_PART_SWAP}"
  fi

  parted -a opt --script "$ARG_ROOT_DISK" -- mklabel gpt
  parted -a opt --script "$ARG_ROOT_DISK" -- mkpart primary-1 1MiB 100%
  DISK_PART_ROOT="${ARG_ROOT_DISK}-part1"
  info "Root partition: ${DISK_PART_ROOT}"

  partprobe "$ARG_BOOT_DISK"
  partprobe "$ARG_ROOT_DISK"
}

function format_and_mount_drives() {
  info "Begin formatting drives..."

  info "Formatting boot partition ..."
  mkfs.fat -F 32 -n boot "$DISK_PART_BOOT"

  if [[ "$ARG_ENABLE_SWAP" = true ]]; then
    info "Creating and mounting swap ..."
    mkswap "$DISK_PART_SWAP"
    swapon "$DISK_PART_SWAP"
  fi

  info "Creating ${ZFS_POOL_NAME} ZFS pool on ${DISK_PART_ROOT} ..."
  # many of these are defaults, setting them anyway so current values are known
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
    "$ZFS_POOL_NAME" \
    "$DISK_PART_ROOT"

  info "Creating ${ZFS_VOLUMES} ZFS dataset ..."
  zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "$ZFS_VOLUMES"

  info "Creating ${ZFS_VOL_SECRETS} ZFS zvol ..."
  zfs create -V 128M $ZFS_VOL_SECRETS

  # zvol device takes a moment to show up
  sleep 2
  parted -a opt --script "$SECRETS_VOL" -- \
    mklabel gpt \
    mkpart "$SECRETS_PART_LABEL" 1MiB 100%
  partprobe "$SECRETS_VOL"
  udevadm settle

  info "Creating boot secrets LUKS device, follow the instructions and use a strong password!"
  info "You'll be asked to unlock with the same password. Alternate methods can be enrolled later."
  cryptsetup luksFormat "$SECRETS_PART"
  cryptsetup luksOpen "$SECRETS_PART" "$SECRETS_LVOL_LABEL"
  mkfs.ext4 "$SECRETS_LVOL"

  info "Mounting ${SECRETS_LVOL} to ${MNT}/bootsecrets ..."
  mkdir -p "${MNT}/bootsecrets"
  chmod 600 "${MNT}/bootsecrets"
  mount -t ext4 "$SECRETS_LVOL" "${MNT}/bootsecrets"
  # key location in install media
  CRYPT_KEY="${MNT}/bootsecrets/rpoolcrypt.key"
  # key location in live system, (nixos zfs legacy mounts usually handle this complication)
  CRYPT_KEY_LIVE_SYSTEM="/bootsecrets/rpoolcrypt.key"
  od -Anone -x -N 32 -w64 /dev/random | tr -d "[:blank:]" > "$CRYPT_KEY"

  # this is currently aes-256-gcm
  zfs create \
    -o canmount=off \
    -o mountpoint=none \
    -o encryption=on \
    -o keylocation="file://${CRYPT_KEY}" \
    -o keyformat=hex \
    "$ZFS_CRYPT"

  # post key-import, update to live system expectations
  zfs set keylocation="file://${CRYPT_KEY_LIVE_SYSTEM}" "${ZFS_CRYPT}"

  info "Creating ${ZFS_LOCAL} ZFS dataset ..."
  zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "$ZFS_LOCAL"

  info "Creating ${ZFS_SAFE} ZFS dataset ..."
  zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "$ZFS_SAFE"


  info "Creating ${ZFS_DS_ROOT} ZFS dataset ..."
  zfs create -p -o mountpoint=legacy "$ZFS_DS_ROOT"
  info "Creating ${ZFS_SNAPSHOT_BLANK} ZFS rollback snapshot ..."
  zfs snapshot "$ZFS_SNAPSHOT_BLANK"
  info "Mounting ${ZFS_DS_ROOT} to ${MNT} ..."
  mount -t zfs "$ZFS_DS_ROOT" "$MNT"

  info "Mounting ${DISK_PART_BOOT} to ${MNT}/boot ..."
  mkdir "${MNT}/boot"
  chmod 700 "${MNT}/boot"
  mount -t vfat "$DISK_PART_BOOT" "${MNT}/boot"

  info "Creating ${ZFS_DS_NIX} ZFS dataset ..."
  zfs create -p -o mountpoint=legacy "$ZFS_DS_NIX"
  info "Mounting ${ZFS_DS_NIX} to ${MNT}/nix ..."
  mkdir "${MNT}/nix"
  mount -t zfs "$ZFS_DS_NIX" "${MNT}/nix"

  info "Creating ${ZFS_DS_PERSIST} ZFS dataset ..."
  zfs create -p -o mountpoint=legacy "$ZFS_DS_PERSIST"
  info "Enable ZFS auto-snapshots on ${ZFS_SAFE} datasets ..."
  zfs set com.sun:auto-snapshot:daily=true "$ZFS_SAFE"
  zfs set com.sun:auto-snapshot:weekly=true "$ZFS_SAFE"
  info "Mounting ${ZFS_DS_PERSIST} to ${MNT}/persist ..."
  mkdir "${MNT}/persist"
  mount -t zfs "$ZFS_DS_PERSIST" "${MNT}/persist"
}

function prepare_drives() {
  if ! ask_yn "Drives will be wiped, continue?"; then
    exit 0
  fi

  info "Begin partitioning disks..."
  blkdiscard -f "$ARG_ROOT_DISK"
  blkdiscard -f "$ARG_BOOT_DISK"

  if [[ "$ARG_ROOT_DISK" == "$ARG_BOOT_DISK" ]]; then
    partition_single_drive
  else
    partition_multi_drive
  fi
  udevadm settle
  parted -l

  format_and_mount_drives
}

function prepare_config() {
  info "Generating hardware-configuration.nix ..."
  HOSTDIR="${ARG_NIX_CONFIG_DIR}/hosts/${ARG_HOSTNAME}"
  HARDWARE_CONFIGURATION="${HOSTDIR}/hardware-configuration.nix"
  info "Generating ${HARDWARE_CONFIGURATION} ..."
  nixos-generate-config --root "$MNT" --show-hardware-config > "$HARDWARE_CONFIGURATION"
  # ensure /persist directories are available for boot
  nix fmt -- -q "$HARDWARE_CONFIGURATION"
  sed -i '/fileSystems\.\"\/persist/aneededForBoot=true;' "$HARDWARE_CONFIGURATION"
  nix fmt -- -q "$HARDWARE_CONFIGURATION"
  (cd "$ARG_NIX_CONFIG_DIR" && git diff "$HARDWARE_CONFIGURATION")
  info "Does this look right?"
  if ! ask_yn "Answer no to open this file for edits"; then
    hx "$HARDWARE_CONFIGURATION"
  fi
  chown 1000:1000 "$HARDWARE_CONFIGURATION"
  info "finalized hardware-configuration.nix:"
  cat "${HARDWARE_CONFIGURATION}"
}

function persist_config() {
  info "persisting ssh keys and config ..."
  mkdir -p "${MNT}/persist/etc/ssh"
  mv "$ARG_SSH_PRIVATE_KEY" "${MNT}/persist/etc/ssh/ssh_host_ed25519_key"
  mv "${ARG_SSH_PRIVATE_KEY}.pub" "${MNT}/persist/etc/ssh/ssh_host_ed25519_key.pub"
  ARG_SSH_PRIVATE_KEY="${MNT}/persist/etc/ssh/ssh_host_ed25519_key"
  (cd "$ARG_NIX_CONFIG_DIR" && git add .)
  mkdir -p "${MNT}/persist/home/spencer"
  chown 1000:1000 "${MNT}/persist/home/spencer"
  mv "$ARG_NIX_CONFIG_DIR" "${MNT}/persist/home/spencer/.nix-config"
  ARG_NIX_CONFIG_DIR="${MNT}/persist/home/spencer/.nix-config"
}

function install_nixos() {
  info "Installing nixos ..."
  nixos-install --root "$MNT" --no-root-passwd --flake "${ARG_NIX_CONFIG_DIR}#${ARG_HOSTNAME}"
  info "Installation complete ..."
}

function cleanup() {
  info "Starting cleanup ..."
  if [[ "$ARG_NO_EXPORT" = true ]]; then
    info "Leaving filesystems mounted for debugging, when done:"
    info "hyperparabolic-export ${MNT}"
    exit 0
  fi

  if [[ "$ARG_ENABLE_SWAP" = true ]]; then
    info "swapoff ..."
    swapoff -a
  fi

  hyperparabolic-export "$MNT"

  if [[ "$ARG_REBOOT" = true ]]; then
    info "Rebooting ..."
    systemctl reboot
    exit 0
  fi

  if [[ "$ARG_POWEROFF" = true ]]; then
    info "Powering off ..."
    systemctl poweroff
    exit 0
  fi

  exit 0
}

function dump_settings() {
  echo "Settings:"
  echo "hostname = '$ARG_HOSTNAME'"
  echo "ssh private key = '$ARG_SSH_PRIVATE_KEY'"
  echo "config directory = '${ARG_NIX_CONFIG_DIR}'"
  echo "root drive device = '$ARG_ROOT_DISK'"
  echo "boot drive device = '$ARG_BOOT_DISK'"
  echo "boot partition size = '$ARG_BOOT_PART_SIZE_GIB' GiB"
  echo "enable swap = '$ARG_ENABLE_SWAP'"
  echo "swap size = '$ARG_SWAP_SIZE_GIB' GiB"
}

function coerce_args() {
  if [[ -z "${ARG_BOOT_DISK}" ]]; then
    ARG_BOOT_DISK=$ARG_ROOT_DISK;
  fi
}

function validate() {
  if ! [[ -f "$ARG_NIX_CONFIG_DIR"/flake.nix ]]; then
    err "Invalid argument: --config '${ARG_NIX_CONFIG_DIR}' must contain a flake"
    exit 1
  fi

  if ! [[ -b $ARG_ROOT_DISK ]]; then
    err "Invalid argument: --root-disk '${ARG_ROOT_DISK}' is not a block special file"
    exit 1
  fi

  if [[ $ARG_ROOT_DISK != "/dev/disk/by-id/"* ]]; then
    err "Invalid argument: --root-disk '${ARG_ROOT_DISK}', use /dev/disk/by-id/..."
    exit 1
  fi

  if ! [[ -b $ARG_BOOT_DISK ]]; then
    err "Invalid argument: --boot-disk '${ARG_BOOT_DISK}' is not a block special file"
    exit 1
  fi

  if [[ $ARG_BOOT_DISK != "/dev/disk/by-id/"* ]]; then
    err "Invalid argument: --boot-disk '${ARG_BOOT_DISK}', use /dev/disk/by-id/..."
    exit 1
  fi

  if [[ $EUID -gt 0 ]]; then
    err "Must run as root"
    exit 1
  fi

  if [[ $(stat -c '%U' "$ARG_SSH_PRIVATE_KEY") != "root" ]]; then
    err "Bad state: --ssh-key '${ARG_SSH_PRIVATE_KEY}' must be owned by the root user"
    exit 1
  fi

  if [[ $(stat -c '%a' "$ARG_SSH_PRIVATE_KEY") != "600" ]]; then
    err "Bad state: --ssh-key '${ARG_SSH_PRIVATE_KEY}' must not be writeable by non-root users"
    exit 1
  fi
}

function main() {
  # : - option requires a following argument
  if ! OPTIONS=$(getopt -o h --long help,hostname:,ssh-key:,config:,boot-disk:,root-disk:,boot-size:,swap,swap-size:,no-export,reboot,poweroff -n 'parse-options' -- "$@"); then
    err "Failed parsing options."
    exit 1
  fi
  eval set -- "$OPTIONS"
  while true; do
    case "$1" in
      -h | --help )         print_help ;;
      --hostname )          ARG_HOSTNAME=$2; shift 2 ;;
      --ssh-key )           ARG_SSH_PRIVATE_KEY=$2; shift 2 ;;
      --config )            ARG_NIX_CONFIG_DIR=$2; shift 2 ;;
      --root-disk )         ARG_ROOT_DISK=$2; shift 2 ;;
      --boot-disk )         ARG_BOOT_DISK=$2; shift 2 ;;
      --boot-size )         ARG_BOOT_PART_SIZE_GIB=$2; shift 2 ;;
      --swap )              ARG_ENABLE_SWAP=true; shift ;;
      --swap-size )         ARG_SWAP_SIZE_GIB=$2; shift 2 ;;
      --no-export )         ARG_NO_EXPORT=true; shift ;;
      --reboot )            ARG_REBOOT=true; shift ;;
      --poweroff )          ARG_POWEROFF=true; shift ;;
      -- )                  shift; break ;;
      * )                   break ;;
    esac
  done

  coerce_args
  dump_settings
  validate
  prepare_drives
  prepare_config
  persist_config
  install_nixos
  cleanup
}

main "${@}"
