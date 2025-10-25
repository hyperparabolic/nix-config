{config, ...}: {
  flake.modules.nixos.hosts-warden = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core

        bluetooth
        reverse-proxy
        secureboot
        ../../../hosts/warden/configuration.nix
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
