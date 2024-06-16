{config, lib, pkgs, ...}: {
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
  ];

  # disable monitor when idle
  services.swayidle = {
    events = [
      {
        # this gets triggered after sleep
        event = "after-resume";
        command = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms on";
      }
      {
        # this system usually doesn't suspend
        # also turn on monitors on unlock
        event = "unlock";
        command = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms on";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms off";
      }
    ];
  };
}
