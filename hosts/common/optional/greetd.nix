{
  config,
  lib,
  pkgs,
  ...
}: {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        # tuigreet with selectable sessions
        command = "${lib.getExe pkgs.tuigreet} --time --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
        user = "greeter";
      };
    };
  };

  environment.persistence."/persist".directories = ["/var/cache/tuigreet"];
}
