# module `this`

Options starting with `this` are options defined by this flake for consumption by this flake. These options rely on conventions defined in this repo, and aren't really meaningful for use elsewhere.

Modules defined in this directory do not modify config. Instead they are just config containers that define options for use in other modules. Since they can't conflict, `this` is consumed as a global module.

## module `this-share-home`

`this` module defines and additional module `this-share-home`. System level and user level concerns aren't always cleanly separated. For options that are relevant to both contexts, the options are defined in both `flake.modules.nixos.this` and `flake.modules.homeManager.this`. For systems that use both nixos and home-manager and import home-manager config into nixos via `home-manager.users`, `this-share-home` automatically imports the home-manager module, and sets the home-manager module options to be the same as the nixos module for all users.

Sharing options this way is opt-in, so it can be ignored for standalone home-manager use or separated nixos and home-manager use.
