# hosts

Subdirectories contain host specific modules. These modules contain hardware specific tweaks for hosts, and services.

Directory structure is important here. Directory names match hostnames, and any directory is used for nixosConfiguration generation in [host-configurations.nix](../flake-parts/host-configurations.nix).

