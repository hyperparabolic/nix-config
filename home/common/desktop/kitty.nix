{
  config,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;

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
