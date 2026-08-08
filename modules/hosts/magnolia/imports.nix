{config, ...}: {
  flake.modules.nixos.hosts-magnolia = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        hyperparabolic
        this
        this-share-home

        audio
        bluetooth
        desktop
        fingerprint
        games
        laptop
        libvirt
        secureboot
        user-spencer
        zfs
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
              hosts-magnolia

              desktop
              desktop-applications
              dev-js
              games
              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-magnolia = {...}: {};
}
