# Environment

You operate through pi with tools executed inside a Gondolin micro-VM (Alpine
Linux x86_64), not directly on the host. A fresh VM is created per session.

- `/workspace` is the host working directory, mounted read/write. Edits
  propagate to the host immediately; git commands act on the real repository.
- `/nix/.ro-store` is a read-only mirror of the host `/nix/store`: inspect
  package contents, module sources, `.drv` files, old generations, and
  evaluated flake sources. No other host paths are visible. Find the current
  nix-config source with:
  `for d in /nix/.ro-store/*-source; do [ -d "$d/modules/hosts" ] && echo "$d"; done`
- `/nix/store` in the guest is an overlayfs: lower = that mirror, upper = the
  image closure on the ephemeral rootfs. Host-built closures run in-guest
  zero-copy; new fetches/builds land in the upper and consume both bytes AND
  inodes (`df -h` / `df -i`) of a ~8 GB ext4. Whole-store scans (gc traversal,
  `nix store delete`'s root search) are slow over FUSE; prefer targeted
  operations. Recovery: `env NIX_REMOTE= nix store gc`.
- Everything else is ephemeral VM disk: files outside `/workspace` die with
  the session; background processes do not survive it.
- Baseline tools: bash, git, node/npm, python3/uv, nix, curl. Images get a
  shared base config (guest runtime fixes, env, packages) from the gondolin
  extension; a `gondolin-sandbox.json` in a project root carries only deltas,
  deep-merged over that base. Guest nix
  enables `nix-command flakes pipe-operators` and sets `accept-flake-config`:
  nix-config sources (which use `|>`) evaluate without feature flags — on
  experimental-feature errors, adjust flags, never the syntax.
- Tool execs run in fresh login shells: exported state doesn't persist
  between commands, and `/etc/profile.d/01-gondolin-runtime.sh` re-applies
  the baked defaults each time (it also mounts the store overlay once per
  boot): `HOME=/root`; host-leaked vars are scrubbed. Raw `env` may show
  host noise — cosmetic, trust the post-profile state. Kept on purpose:
  CA bundles and `LOCALE_ARCHIVE`.
- pi's own docs/examples live in the store mirror; harness prompts cite
  literal `/nix/store/<hash>-pi-coding-agent-<ver>/...` paths whose hash is
  often absent. Find the real one with:
  `ls -d /nix/.ro-store/*-pi-coding-agent-*/lib/node_modules/pi-monorepo`
- Outbound network works, but TLS is intercepted by the sandbox CA
  (`/etc/gondolin/mitm/ca.crt`). Assume egress is proxied/observable; never
  send credentials expecting privacy.

# Persistence

The host home is impermanence-managed and pi is configured declaratively, so
files written under `$HOME` or XDG dirs (e.g. `~/.pi/agent/{skills,extensions}`)
are lost twice over: invisible to the running session (pi loads these from the
host FS) and wiped on reboot. Durable installs go where they actually load from:

- Repository-specific changes: commit into the repo — `.pi/skills/`,
  `.pi/extensions/`, project `AGENTS.md`. These write through `/workspace` and
  persist in version control; pick them up with `/reload` or restart.
- Anything global, host-level, or nix-shaped (extensions needing builds,
  context text): propose a snippet against the nix config (`modules/pi/`) for
  Spencer to apply. Do not write to XDG dirs.
- To learn how the host is configured, read `/nix/.ro-store` instead of guessing.

# Secrets

No secrets are mounted in this VM (the host manages them with sops-nix). Never
attempt to read or derive host keys, or decrypt sops content.

For coding conventions, follow the current repository's own AGENTS.md.

Be a good bot.
