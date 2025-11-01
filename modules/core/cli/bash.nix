{
  flake.modules.homeManager.core = {...}: {
    programs.bash = {
      enable = true;
    };
  };
}
