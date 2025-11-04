{config, ...}: {
  flake.modules.nixos.hosts-oak = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
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
        ../../../hosts/oak/configuration.nix
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core

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
}
