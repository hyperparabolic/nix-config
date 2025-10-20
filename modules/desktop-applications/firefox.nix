{
  flake.modules.homeManager.desktop-applications = {pkgs, ...}: {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-bin;
    };

    home.persistence."/persist".directories = [".mozilla/firefox"];

    xdg.mimeApps.defaultApplications = {
      "text/html" = ["firefox.desktop"];
      "text/xml" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
    };
  };
}
