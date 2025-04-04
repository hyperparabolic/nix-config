# Helper, mounts a LUKS on ZFS filesystem without booting in debug / install media.

# args and defaults
ARG_MOUNT_DIR=""

# zfs names
ZFS_POOL_NAME="rpool"

# volume, LUKS encrypted secrets storage only mounted during boot
# ZFS_VOLUMES="${ZFS_POOL_NAME}/volumes"
# ZFS_VOL_SECRETS="${ZFS_VOLUMES}/bootsecrets"

# encrypted management dataset, keys stored in ZFS_KEY_ZVOL
ZFS_CRYPT="${ZFS_POOL_NAME}/crypt"

# local datasets, ephemeral or trivially reproduced
ZFS_LOCAL="${ZFS_CRYPT}/local"
ZFS_DS_ROOT="${ZFS_LOCAL}/root"
# ZFS_SNAPSHOT_BLANK="${ZFS_DS_ROOT}@blank"
ZFS_DS_NIX="${ZFS_LOCAL}/nix"

# safe datasets, user data and persisted runtime data, autosnapshot and remote backups
ZFS_SAFE="${ZFS_CRYPT}/safe"
ZFS_DS_PERSIST="${ZFS_SAFE}/persist"

# ZFS_VOL_SECRETS partition / logical volume names
# SECRETS_VOL="/dev/zvol/${ZFS_VOL_SECRETS}"
SECRETS_PART_LABEL=cryptroot
SECRETS_PART="/dev/disk/by-partlabel/${SECRETS_PART_LABEL}"
SECRETS_LVOL_LABEL=secretsroot
SECRETS_LVOL="/dev/mapper/${SECRETS_LVOL_LABEL}"

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

function print_help() {
  printf "%b" "
Import a LUKS on ZFS fs without a booting system.

  $(basename "${BASH_SOURCE[0]}") [options] [MOUNT_DIR]

Options:

    -h --help           Display this help message

Arguments:

    MOUNT_DIR           Optional, temporary directory to mount fs in.
"
  exit 0
}

function main() {
  # :  - required
  # :: - optional
  if ! OPTIONS=$(getopt -o h --long help,mount-dir: -n 'parse-options' -- "$@"); then
    err "Failed parsing options."
    exit 1
  fi
  eval set -- "$OPTIONS"
  while true; do
    case "$1" in
      -h | --help )         print_help ;;
      -- )                  shift; break ;;
      * )                   break ;;
    esac
  done
  POS_ARGS=("${@:$OPTIND:1}")
  if [[ ${#POS_ARGS[@]} -gt 0 ]]; then
    ARG_MOUNT_DIR="${POS_ARGS[0]}"
  fi

  if [[ ! -d "$ARG_MOUNT_DIR" ]]; then
    ARG_MOUNT_DIR=$(mktemp -d)
    info "Mounting filesystem at temporary directory ${ARG_MOUNT_DIR} ..."
  fi
  MNT=$ARG_MOUNT_DIR

  info "Importing ${ZFS_POOL_NAME}"
  zpool import "${ZFS_POOL_NAME}"

  info "Opening ${SECRETS_LVOL_LABEL} ..."
  cryptsetup luksOpen "$SECRETS_PART" "$SECRETS_LVOL_LABEL"

  info "Mounting ${SECRETS_LVOL} to ${MNT}/bootsecrets ..."
  mkdir -p "${MNT}/bootsecrets"
  mount -t ext4 "$SECRETS_LVOL" "${MNT}/bootsecrets"

  info "Loading keys ..."
  zfs load-key -L "file://${MNT}/bootsecrets/rpoolcrypt.key" "$ZFS_CRYPT"

  info "Mounting ${ZFS_DS_ROOT} to ${MNT} ..."
  mount -t zfs "$ZFS_DS_ROOT" "$MNT"

  info "Mounting /dev/disk/by-partlabel/ESP to ${MNT}/boot ..."
  mkdir -p "${MNT}/boot"
  mount -t vfat /dev/disk/by-partlabel/ESP "${MNT}/boot"

  info "Mounting ${ZFS_DS_NIX} to ${MNT}/nix ..."
  mkdir -p "${MNT}/nix"
  mount -t zfs "$ZFS_DS_NIX" "${MNT}/nix"

  info "Mounting ${ZFS_DS_PERSIST} to ${MNT}/persist ..."
  mkdir -p "${MNT}/persist"
  mount -t zfs "$ZFS_DS_PERSIST" "${MNT}/persist"

  exit 0
}

main "${@}"
