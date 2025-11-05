{config, ...}: {
  flake.modules.nixos.hosts-warden = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        this
        this-share-home

        bluetooth
        reverse-proxy
        secureboot
        user-spencer
        tailscale-exit-node
        zfs
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
              hosts-warden

              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-warden = {...}: {};
}
