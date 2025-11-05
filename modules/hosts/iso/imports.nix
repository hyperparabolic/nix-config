{config, ...}: {
  flake.modules.nixos.hosts-iso = {inputs, ...}: {
    imports = with config.flake.modules.nixos;
      [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        core
        this
        this-share-home
        user-spencer
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
              hosts-iso

              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-iso = {...}: {};
}
