{
  config,
  lib,
  pkgs,
  ...
}: let
in {
  services.greetd = {
    enable = true;
    # non default tty ensures systemd logs do not interfere with tuigreet
    vt = 2;
    settings = {
      default_session = {
        # tuigreet with selectable sessions
        command = "${lib.getExe pkgs.greetd.tuigreet} --time --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
        user = "greeter";
      };
    };
  };

  # persist tuigreet state
  environment.persistence."/persist".directories = [
    "/var/cache/tuigreet"
  ];
}
