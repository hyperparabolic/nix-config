{config, ...}: {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
    };
  };

  stylix.targets.zathura.enable = true;

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = ["zathura.desktop"];
  };
}
