# Remote bootstrapping prep for ./hyperparabolic-install.sh
#
# This handles generation / encryption of secrets on a trusted host
# before handing installation off to the install media. Modifies
# ~/.nix-config/.sops.yaml.

set -euo pipefail

# args and defaults
ARG_TARGET=""
ARG_TS_AUTH_KEY=""
ARG_HOSTNAME=""


TEMPDIR=$(mktemp -d)
TEMP_SSH="${TEMPDIR}/ssh"
mkdir "$TEMP_SSH"

SSH_PORT="22"

# logging
export COLOR_RESET="\033[0m"
export RED_BG="\033[41m"
export BLUE_BG="\033[44m"

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
Bootstrap repo for remote hyperparabolic-install.

  $(basename "${BASH_SOURCE[0]}") [options]

Options:

    -h --help           Display this help message
    --target            Hostname or IP to install on
    --ts-auth-key       Ephemeral, non-reusable tailscale auth key
    --hostname          Device hostname
"
  exit 0
}

function main() {
  # :  - required
  # :: - optional
  if ! OPTIONS=$(getopt -o h --long help,target:,ts-auth-key:,hostname: -n 'parse-options' -- "$@"); then
    err "Failed parsing options."
    exit 1
  fi
  eval set -- "$OPTIONS"
  while true; do
    case "$1" in
      -h | --help )         print_help ;;
      --target )            ARG_TARGET=$2; shift 2 ;;
      --ts-auth-key )       ARG_TS_AUTH_KEY=$2; shift 2 ;;
      --hostname )          ARG_HOSTNAME=$2; shift 2 ;;
      -- )                  shift; break ;;
      * )                   break ;;
    esac
  done

  SSH_CMD="ssh -oport=${SSH_PORT} -t ${ARG_TARGET}"

  # authenticate target
  info "connecting remote host to vpn ..."
  $SSH_CMD "sudo tailscale up --auth-key ${ARG_TS_AUTH_KEY}"

  # provision ssh key and copy to repo
  info "generating ssh keys on remote host ..."
  # this creates keys in /home/spencer/*, but owned by the root user
  $SSH_CMD "sudo ssh-keygen -t ed25519 -N \"\" -C \"root@${ARG_HOSTNAME}\" -f ~/ssh_host_ed25519_key"
  $SSH_CMD "cat ~/ssh_host_ed25519_key.pub" > ~/.nix-config/secrets/"$ARG_HOSTNAME"/ssh_host_ed25519_key.pub
  info "public key:"
  cat ~/.nix-config/secrets/"$ARG_HOSTNAME"/ssh_host_ed25519_key.pub
  AGE_KEY=$(ssh-to-age -i ~/.nix-config/secrets/"$ARG_HOSTNAME"/ssh_host_ed25519_key.pub)
  info "age key:"
  echo "${AGE_KEY}"

  # update sops
  info "Updating sops keys ..."
  TEMP_SOPS=$(mktemp)
  yq ".keys += (\"${AGE_KEY}\" | . anchor = \"${ARG_HOSTNAME}\") | (.creation_rules[] | select(.path_regex == \"secrets/common/secrets.*$\")).key_groups[0].age += ((.keys[-1] | anchor) | . alias |= .)" ~/.nix-config/.sops.yaml > "$TEMP_SOPS" && mv "$TEMP_SOPS" ~/.nix-config/.sops.yaml
  cat ~/.nix-config/.sops.yaml
  info "Does this look right? There may be extraneous config if reprovisioning."
  if ! ask_yn "Answer no to open this file for edits"; then
    hx ~/.nix-config/.sops.yaml
  fi
  info "Updating sops secrets ..."
  sops updatekeys ~/.nix-config/secrets/*/secrets*.yaml


  # prepare stripped repo
  info "preparing repo copy to send to target ..."
  cp -r ~/.nix-config "$TEMPDIR"
  info "copying ~/.nix-config to ${TEMPDIR}"
  cd "${TEMPDIR}/.nix-config"
  # clean all branches but main and current
  info "cleaning extraneous branches"
  git branch | grep --color=auto -v 'main' | grep --color=auto -v "$(git branch --show-current)" | xargs git branch -D

  # copy files and cleanup local
  info "copying repo to target ..."
  rsync -rz --exclude=result --rsh="ssh -oport=${SSH_PORT}" "${TEMPDIR}/.nix-config" "${ARG_TARGET}:~/"

  # ssh
  info "ssh to host for install ..."
  $SSH_CMD "hyperparabolic-install --help"
  info "sudo hyperparabolic-install --hostname ${ARG_HOSTNAME} --ssh-key ~/ssh_host_ed25519_key --config ~/.nix-config"
  ssh -oport="$SSH_PORT" "$ARG_TARGET"
}

main "${@}"
