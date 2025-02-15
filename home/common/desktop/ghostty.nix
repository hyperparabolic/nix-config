{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      "scrollback-limit" = 4294967295;
      "window-decoration" = false;
      "window-padding-x" = 20;
      "window-padding-y" = 20;
    };
  };

  xdg.mimeApps = {
    associations.added = {
      "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
    };
    defaultApplications = {
      "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
    };
  };
}
