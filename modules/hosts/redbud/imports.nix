{config, ...}: {
  flake.modules.nixos.hosts-redbud = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        this
        this-share-home

        audio
        bluetooth
        laptop
        pipewire-raop
        reverse-proxy
        secureboot
        user-spencer
        ../../../hosts/redbud/configuration.nix
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core

              user-spencer
            ];
          };
        }
      ];
  };
}
