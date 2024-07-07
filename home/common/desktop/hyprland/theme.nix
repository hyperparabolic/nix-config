{
  pkgs,
  config,
  ...
}: {
  gtk = {
    enable = true;

    cursorTheme = {
      name = "macOS-Monterey";
      package = pkgs.apple-cursor;
      size = 20;
    };

    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Colloid-Yellow-Dark-Compact-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        colorVariants = ["dark"];
        sizeVariants = ["compact"];
        themeVariants = ["yellow"];
        tweaks = ["catppuccin" "rimless" "black"];
      };
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS-Monterey";
    size = 20;
  };
}
