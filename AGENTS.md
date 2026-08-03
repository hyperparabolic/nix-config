# nix-config Conventions

## Repository

nix-config is a public monorepo defining Spencer's home lab and personal computers.

## Modules Concepts

This repo implements the [dendritic](https://github.com/mightyiam/dendritic) nix pattern. Every file in the modules directory is a flake-parts module, and they are all recursively imported in flake.nix. These modules are grouped by feature sets, and files may contain both nixos or homeManager modules.

Modules named:
- `flake.modules.nixos.<feature> = {...}:` are nixos modules
- `flake.modules.homeManager.<feature> = {...}:` are homeManager modules.
Where `<feature>` describes a program, service, or functional or logical grouping, and generally matches the directory the module lives in. `<feature>` is also an import group.

## Directory Structure

```
.
├── .sops.yaml                # SOPS keys and file rules
├── flake.nix                 # flake entrypoint, inputs, flake-parts init, and recursive import
├── modules/                  # flake-parts modules
│   ├── <feature>/            # logical grouping, entire module gets imported together
│   │   ├── default.nix       # module entrypoint and primary config
│   │   ├── *.nix             # additional tools, software, or split config
│   ├── flake-parts/          # flake modules, define attributes of the traditional flake schema
│   ├── hosts/                # host modules, one per nixosConfigurations
│   │   ├── <hostname>/       # per host config (magnolia, oak, redbud, warden)
│   │   │   ├── default.nix   # host specific external `inputs` imports and config
│   │   │   ├── imports.nix   # host module imports
│   │   │   └── services/     # host specific services
│   ├── hyperparabolic/       # modules structred for import in external flakes
│   └── this/                 # config container modules for re-use in this repo
├── scripts/                  # bootable usb stick debugging and bootstrapping bash scripts
├── secrets/                  # SOPS secrets, structured by hosts and services
└── templates/                # nix flake language specific development templates
```

## Secrets

- Secrets are managed with `sops-nix` (nix module) and `pass` password manager.
  - User keys both are PGP encryption key `C4DCAD1C91E50F606D1622F1C809ED22329061CE` on Spencer's YubiKey.
- **NEVER** attempt to read or derive host AGE keys.
- **NEVER** read secrets into context.
- Ask Spencer to update secrets asynchronously, providing a YAML template or `pass` path as appropriate.

## Code Style

- LF newlines.
- 2 space indentation, no tabs.
- Format files with alejandra, `nix fmt -- -q [files...]`. Format all changed files.
