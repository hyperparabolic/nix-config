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
}
