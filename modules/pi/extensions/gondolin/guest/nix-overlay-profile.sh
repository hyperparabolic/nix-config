# Guest runtime fixes for the Gondolin nix-config sandbox.
# Sorted 01- so it runs before Alpine's 20locale.sh and nix profile scripts:
# it must scrub host-leaked state guards first and pin HOME/NIX_* before
# nix-daemon.sh consumes them.

# Host environment leaks through tool exec; normalize what breaks here.
# This part is cheap and MUST run in every shell: each tool exec starts a
# fresh login shell with a leaked host environment, so none of it can be
# cached or skipped.
export HOME=/root
export NIX_REMOTE=	# single-user root; nix-remote.sh is removed at build

# Leaked guard variables make Alpine's own profile scripts think they already
# ran (on the host); clear them so the guest's scripts execute normally.
unset __ETC_PROFILE_NIX_SOURCED __NIXOS_SET_ENVIRONMENT_DONE
unset __fish_nixos_env_preinit_sourced

# Host nix vars pointing at nonexistent guest paths.
unset NIXPKGS_CONFIG	# /etc/nix/nixpkgs-config.nix does not exist here
unset NIX_PATH		# host channels; use flakes instead
unset NIX_PROFILES NIX_USER_PROFILE_DIR	# re-derived by nix-daemon.sh below

# Repoint XDG homes at root's; leaked values reference /home/spencer/*,
# which does not exist in the guest. Reset DATA_DIRS to the XDG default;
# nix-daemon.sh appends profile share dirs afterwards.
export XDG_CONFIG_HOME=/root/.config
export XDG_DATA_HOME=/root/.local/share
export XDG_CACHE_HOME=/root/.cache
export XDG_STATE_HOME=/root/.local/state
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_RUNTIME_DIR=/run/user/0
mkdir -p "$XDG_RUNTIME_DIR" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" \
	"$XDG_CACHE_HOME" "$XDG_STATE_HOME"
chmod 700 "$XDG_RUNTIME_DIR"

# Curated subset of Hyprland/desktop leftovers from the host: the ones that
# actively break child processes here, not mere noise in `env` output.
unset DBUS_SESSION_BUS_ADDRESS HYPRLAND_CMD HYPRLAND_LUA_STUBS NIXOS_OZONE_WL
unset GTK_PATH QML2_IMPORT_PATH QT_PLUGIN_PATH GIO_EXTRA_MODULES XCURSOR_PATH
unset NIX_XDG_DESKTOP_PORTAL_DIR LIBEXEC_PATH XDG_MENU_PREFIX
unset XDG_BACKEND XDG_CURRENT_DESKTOP XDG_SEAT XDG_SESSION_DESKTOP
unset XDG_SESSION_ID XDG_SESSION_TYPE XDG_VTNR

# Deliberately kept:
# - LOCALE_ARCHIVE: resolves through the store overlay lowerdir and gives
#   host-built glibc binaries working locales.
# - CA/cert bundles (SSL_CERT_FILE, CURL_CA_BUNDLE, REQUESTS_CA_BUNDLE,
#   NODE_EXTRA_CA_CERTS, NIX_SSL_CERT_FILE): verified working for guest egress.
# - PATH head entries under /home/spencer: nonexistent dirs are skipped.

# Overlay the read-only host store (sandboxd FUSE at /nix/.ro-store) onto
# /nix/store so host-built closures resolve their absolute /nix/store rpaths
# and execute in-guest zero-copy. The image's own store closure becomes the
# writable upper. Image builds are unprivileged, so the initial split happens
# here; sandboxd serves the FUSE mount only after init, so mounting also
# happens here rather than during init.
#
# Every bash invocation is a fresh login shell, so this block is guarded to
# run at most once per boot: concurrent shells serialize on a lock dir, and a
# tmpfs sentinel records success (/run is cleared on reboot). A failed attempt
# sets neither marker, so a later shell retries from a consistent state; if a
# shell dies mid-setup the lock dir survives until reboot and setup is skipped
# for the rest of the boot — degraded but safe, never destructive.
setup_store_overlay() {
	# Already mounted?
	grep -qs ' /nix/store overlay ' /proc/mounts && return 0
	# Wait briefly for sandboxd's FUSE store mirror to be served; mounting
	# against a not-yet-served FUSE mount fails. If it never appears, bail
	# without touching anything — a later shell will retry.
	i=0
	while [ "$i" -lt 50 ] && ! grep -qs ' /nix/.ro-store ' /proc/mounts; do
		i=$((i + 1))
		sleep 0.1 2>/dev/null
	done
	grep -qs ' /nix/.ro-store ' /proc/mounts || return 1
	# Recover a half-finished previous attempt first: an upper without its
	# store means a prior rollback died between rmdir and mv.
	if [ -d /nix/store.upper ] && [ ! -e /nix/store ]; then
		mv /nix/store.upper /nix/store || return 1
	fi
	# A fresh image may ship no store dir at all (nothing injects a closure
	# and Alpine's nix apk does not pre-create it). Create an empty one so it
	# becomes the overlay upper; bailing here would leave every shell without
	# a usable /nix/store until some nix command happens to create the dir.
	[ -d /nix/store ] || { mkdir /nix/store || return 1; }
	# Fresh image: move the image closure aside to become the overlay upper.
	if [ ! -d /nix/store.upper ]; then
		mv /nix/store /nix/store.upper || return 1
		mkdir /nix/store || {
			mv /nix/store.upper /nix/store
			return 1
		}
	fi
	mkdir -p /nix/store.work
	if mount -t overlay overlay \
		-o lowerdir=/nix/.ro-store,upperdir=/nix/store.upper,workdir=/nix/store.work \
		/nix/store 2>/dev/null; then
		return 0
	fi
	# Non-destructive rollback: drop only the empty mountpoint we created,
	# never rm -rf under /nix. If rmdir fails because the store somehow has
	# content, leave everything as-is; the next shell retries the mount.
	rmdir /nix/store 2>/dev/null &&
		mv /nix/store.upper /nix/store 2>/dev/null
	rmdir /nix/store.work 2>/dev/null
	return 1
}
if [ ! -e /run/gondolin-store-overlay.ready ] &&
	mkdir /run/gondolin-store-overlay.lock 2>/dev/null; then
	if setup_store_overlay; then
		: > /run/gondolin-store-overlay.ready
	fi
	rmdir /run/gondolin-store-overlay.lock 2>/dev/null
fi
