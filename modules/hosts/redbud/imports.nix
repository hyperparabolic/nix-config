{config, ...}: {
  flake.modules.nixos.hosts-redbud = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core

        bluetooth
        laptop
        ../../../hosts/redbud/configuration.nix
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
            ];
          };
        }
      ];
  };
}
