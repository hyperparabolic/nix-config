{config, ...}: {
  flake.modules.nixos.hosts-pando1 = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        hyperparabolic
        this
        this-share-home

        audio
        bluetooth
        pipewire-raop
        reverse-proxy
        stage1-ssh
        user-spencer
        zfs
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
              hosts-pando1

              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-pando1 = {...}: {};
}
