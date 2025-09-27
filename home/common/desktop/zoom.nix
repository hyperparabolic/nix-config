{pkgs, ...}: {
  home.packages = with pkgs; [
    zoom-us
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/zoommtg" = "Zoom.desktop";
  };

  home.persistence."/persist".directories = [".zoom"];
}
