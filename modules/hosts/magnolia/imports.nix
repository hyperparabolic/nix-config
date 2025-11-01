{config, ...}: {
  flake.modules.nixos.hosts-magnolia = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        this
        this-share-home

        audio
        bluetooth
        fingerprint
        games
        laptop
        secureboot
        user-spencer
        ../../../hosts/magnolia/configuration.nix
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core

              desktop-applications
              dev-js
              games
              user-spencer
            ];
          };
        }
      ];
  };
}
