{
  flake.modules.homeManager.core = {...}: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
