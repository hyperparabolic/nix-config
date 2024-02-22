{config, ...}: {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      font = "${config.fontProfiles.regular.family} 12";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = ["zathura.desktop"];
  };
}
