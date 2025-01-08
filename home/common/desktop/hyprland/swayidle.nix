{
  config,
  lib,
  ...
}: let
  inherit (lib) getExe;
in {
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${getExe config.programs.swaylock.package} -defF";
      }
      {
        event = "lock";
        command = "${getExe config.programs.swaylock.package} -defF";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${getExe config.programs.swaylock.package} -defF";
      }
    ];
  };

  systemd.user.timers.swayidle-night = {
    Unit = {
      Description = "Ensures swayidle is renabled at night";
    };
    Timer = {
      OnCalendar = "*-*-* 02:00:00";
      Unit = "swayidle.service";
    };
  };
}
