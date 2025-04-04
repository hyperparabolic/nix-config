# Helper, unmounts, closes, and exports LUKS on ZFS filesystem after install or debug mount.

# args and defaults
ARG_MOUNT_DIR=""

# zfs names 
ZFS_POOL_NAME="rpool"

# volume, LUKS encrypted secrets storage only mounted during boot
# ZFS_VOLUMES="${ZFS_POOL_NAME}/volumes"
# ZFS_VOL_SECRETS="${ZFS_VOLUMES}/bootsecrets"

# encrypted management dataset, keys stored in ZFS_KEY_ZVOL
# ZFS_CRYPT="${ZFS_POOL_NAME}/crypt"

# local datasets, ephemeral or trivially reproduced
# ZFS_LOCAL="${ZFS_CRYPT}/local"
# ZFS_DS_ROOT="${ZFS_LOCAL}/root"
# ZFS_SNAPSHOT_BLANK="${ZFS_DS_ROOT}@blank"
# ZFS_DS_NIX="${ZFS_LOCAL}/nix"

# safe datasets, user data and persisted runtime data, autosnapshot and remote backups
# ZFS_SAFE="${ZFS_CRYPT}/safe"
# ZFS_DS_PERSIST="${ZFS_SAFE}/persist"

# ZFS_VOL_SECRETS partition / logical volume names
# SECRETS_VOL="/dev/zvol/${ZFS_VOL_SECRETS}"
# SECRETS_PART_LABEL=cryptroot
# SECRETS_PART="/dev/disk/by-partlabel/${SECRETS_PART_LABEL}"
SECRETS_LVOL_LABEL=secretsroot
# SECRETS_LVOL="/dev/mapper/${SECRETS_LVOL_LABEL}"

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
Export filesystem after install or debugging, unmounting partitions, closing LUKS volumes, and exporting ZFS pools.

  $(basename "${BASH_SOURCE[0]}") [options] MOUNT_DIR

Options:

    -h --help           Display this help message

Arguments:

    MOUNT_DIR           Temporary directory the filesystem is mounted in.
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
  ARG_MOUNT_DIR="${POS_ARGS[0]}"

  if [[ ! -d "$ARG_MOUNT_DIR" ]]; then
    err "Mounted directory must be specified"
    info "hyperparabolic-export MOUNT_DIR"
    exit 1
  fi
  MNT=$ARG_MOUNT_DIR

  info "Unmounting ${MNT}"
  umount -lR "$MNT"

  info "Closing bootsecrets"
  umount -lR "${MNT}/bootsecrets"
  cryptsetup luksClose "$SECRETS_LVOL_LABEL"

  info "Exporting ${ZFS_POOL_NAME}"
  zpool export "$ZFS_POOL_NAME"

  exit 0
}

main "${@}"
