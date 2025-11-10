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

              desktop
              desktop-applications
              dev-js
              libvirt
              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-oak = {...}: {};
}
