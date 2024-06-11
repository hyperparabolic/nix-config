{
  config,
  lib,
  pkgs,
  ...
}: let
  homeCfg = config.home-manager.users.spencer;
in {
  users.extraUsers.greeter = {
    packages = [
      pkgs.cage
      homeCfg.gtk.theme.package
      homeCfg.gtk.iconTheme.package
    ];
    home = "/tmp/greeter-home";
    createHome = true;
  };

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        icon_theme_name = homeCfg.gtk.iconTheme.name;
        theme_name = homeCfg.gtk.theme.name;
      };
    };
  };

  services.greetd = {
    enable = true;
    settings= {
      default_session.command = "${lib.getExe pkgs.cage} -- ${lib.getExe config.programs.regreet.package}";
      initial_session = {
        command = "Hyprland";
        user = "spencer";
      };
    };
  };

  # unlock gpg keyring on login
  security.pam.services.greetd.enableGnomeKeyring = true;
}
