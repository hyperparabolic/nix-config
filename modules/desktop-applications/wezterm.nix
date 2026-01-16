{
  flake.modules.homeManager.desktop-applications = {...}: {
    programs.wezterm = {
      enable = true;
      extraConfig =
        /*
        lua
        */
        ''
          config.hide_tab_bar_if_only_one_tab = true;
          config.window_padding = {
            left = 5,
            right = 5,
            top = 1,
            bottom = 1,
          }
        '';
    };

    stylix.targets.wezterm.enable = true;
  };
}
