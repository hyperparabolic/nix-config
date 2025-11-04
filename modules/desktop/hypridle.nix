{
  flake.modules.homeManager.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          # lock if hyprlock process doesn't exist, or turn off monitor if repeated
          lock_cmd = "${lib.getExe' pkgs.procps "pidof"} -q hyprlock && ${lib.getExe' pkgs.coreutils-full "sleep"} 1 && ${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms off || ${lib.getExe config.programs.hyprlock.package}";
          before_sleep_cmd = "${lib.getExe' pkgs.procps "pidof"} hyprlock || ${lib.getExe config.programs.hyprlock.package} --immediate --no-fade-in";
          after_sleep_cmd = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
          }
          {
            timeout = 330;
            on-resume = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms on";
            on-timeout = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms off";
          }
        ];
      };
    };
  };
}
