{ pkgs, ... }: {
  home.packages = with pkgs; [
    krita
  ];

  xdg.mimeApps.defaultApplications = {
    "image/apng" = [ "krita.desktop" ];
    "image/avif" = [ "krita.desktop" ];
    "image/gif" = [ "krita.desktop" ];
    "image/jpeg" = [ "krita.desktop" ];
    "image/png" = [ "krita.desktop" ];
    "image/svg+xml" = [ "krita.desktop" ];
    "image/webp" = [ "krita.desktop" ];
  };
}
