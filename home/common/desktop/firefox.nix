{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
  };

  home.persistence = {
    "/persist/home/spencer".directories = [ ".mozilla/firefox" ];
  };

  # also add unconfigured developer edition
  home.packages = with pkgs; [
    firefox-devedition-bin
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
