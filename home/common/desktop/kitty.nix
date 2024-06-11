{
  config,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;

    font = {
      name = config.fontProfiles.monospace.family;
      size = 12;
    };

    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
    };

    settings = {
      # configure manually in rc files
      shell_integration = "no-rc";
      scrollback_lines = 4000;
      scrollback_pager_history_size = 2048;
      scrollback_fill_enlarged_window = "yes";

      # ui
      hide_window_decorations = "yes";
      window_padding_width = 15;
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "angled";

      # make it pretty TODO: find or make a module for color scheme
      # Pulled from "Nord" color theme
      background_opacity = "0.9";
      foreground = "#D8DEE9";
      background = "#2E3440";
      selection_foreground = "#000000";
      selection_background = "#FFFACD";
      url_color = "#0087BD";
      cursor = "#81A1C1";

      # black
      color0 = "#3B4252";
      color8 = "#4C566A";

      # red
      color1 = "#BF616A";
      color9 = "#BF616A";

      # green
      color2 = "#A3BE8C";
      color10 = "#A3BE8C";

      # yellow
      color3 = "#EBCB8B";
      color11 = "#EBCB8B";

      # blue
      color4 = "#81A1C1";
      color12 = "#81A1C1";

      # magenta
      color5 = "#B48EAD";
      color13 = "#B48EAD";

      # cyan
      color6 = "#88C0D0";
      color14 = "#8FBCBB";

      # white
      color7 = "#E5E9F0";
      color15 = "#ECEFF4";
    };
  };

  xdg.mimeApps = {
    associations.added = {
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
  };
}
