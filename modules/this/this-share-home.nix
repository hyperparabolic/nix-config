topLevel: {
  flake.modules.nixos.this-share-home = {...}: {
    home-manager = {
      sharedModules = with topLevel.config.flake.modules.homeManager; [
        this
      ];
    };
  };
}
