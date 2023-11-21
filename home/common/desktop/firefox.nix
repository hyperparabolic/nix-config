{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
  };

  home.persistence = {
    "/persist/home/spencer".directories = [ ".mozilla/firefox" ];
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
