{config, ...}: {
  flake.modules.nixos.hosts-oak = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        hyperparabolic
        this
        this-share-home

        audio
        bluetooth
        desktop
        games
        libvirt
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
              hosts-oak

              ai
              ai-pi
              desktop
              desktop-applications
              dev-js
              games
              guitar-pro
              libvirt
              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-oak = {...}: {};
}
