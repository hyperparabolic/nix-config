# iso

Local iso builds for installation and debugging media.

Features:
- Generated locally, no need to verify hashes or worry about trust
- sshd is preconfigured, and trusts my yubikey exclusively
- All necessary bootstrapping utilities (gnupg, sops, etc...) included
- Full nix cli development environment included

## Building

```
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```
