{config, ...}: {
  flake.modules.nixos.hosts-warden = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        this
        this-share-home

        bluetooth
        reverse-proxy
        secureboot
        user-spencer
        ../../../hosts/warden/configuration.nix
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
