{config, ...}: {
  flake.modules.nixos.hosts-oak = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core

        audio
        bluetooth
        ../../../hosts/oak/configuration.nix
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core

              desktop-applications
            ];
          };
        }
      ];
  };
}
