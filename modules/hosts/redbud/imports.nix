{config, ...}: {
  flake.modules.nixos.hosts-redbud = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        hyperparabolic
        this
        this-share-home

        audio
        bluetooth
        laptop
        pipewire-raop
        reverse-proxy
        secureboot
        user-spencer
        zfs
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
              hosts-redbud

              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-redbud = {...}: {};
}
