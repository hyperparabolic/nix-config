{
  pkgs,
  config,
  ...
}: {
  gtk = {
    enable = true;

    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Orchis";
      package = pkgs.orchis-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = "1";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = "1";
    };
  };

  home.sessionVariables.GTK_THEME = "Orchis";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Orchis";
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.user-themes
    orchis-theme
  ];
}
