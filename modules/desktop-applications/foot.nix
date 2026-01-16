{
  flake.modules.homeManager.desktop-applications = {...}: {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          # ${x_pad}x${y_pad}
          pad = "5x1 center-when-maximized-and-fullscreen";
        };
      };
    };

    stylix.targets.foot = {
      enable = true;
    };
  };
}
