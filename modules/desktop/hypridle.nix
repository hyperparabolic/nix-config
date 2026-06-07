{
  flake.modules.homeManager.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    services.hypridle = {
      enable = true;
      settings = let
        hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
        hyprlock = lib.getExe config.programs.hyprlock.package;
        loginctl = lib.getExe' pkgs.systemd "loginctl";
        pidof = lib.getExe' pkgs.procps "pidof";
      in {
        general = {
          # lock if hyprlock process doesn't exist, or turn off monitor if repeated
          lock_cmd = "${pidof} -q hyprlock || ${hyprlock}";
          before_sleep_cmd = "${pidof} -q hyprlock || ${hyprlock} --immediate --no-fade-in";
          after_sleep_cmd = "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "${loginctl} lock-session";
          }
          {
            timeout = 330;
            on-resume = "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
            on-timeout = "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          }
        ];
      };
    };
  };
}
