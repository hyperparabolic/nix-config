{config, ...}: {
  flake.modules.nixos.hosts-magnolia = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core

        audio
        bluetooth
        fingerprint
        laptop
        secureboot
        ../../../hosts/magnolia/configuration.nix
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
