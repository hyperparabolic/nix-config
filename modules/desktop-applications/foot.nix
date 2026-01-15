{
  flake.modules.homeManager.desktop-applications = {...}: {
    programs.foot = {
      enable = true;
      settings = {
      };
    };

    stylix.targets.foot = {
      enable = true;
    };
  };
}
