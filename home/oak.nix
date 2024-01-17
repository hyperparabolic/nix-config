{ config, lib, ... }:
let
  inherit (lib) getExe';
in
{
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
  ];

  monitors = [
    {
      name = "HDMI-A-2";
      width = 3840;
      height = 2160;
      x = 0;
      primary = true;
      workspaces = [
        "1"
        "2"
        "5"
        "6"
      ];
    }
    {
      name = "DP-1";
      width = 1920;
      height = 1080;
      x = 3840;
      # vertical orientation
      transform = 3;
      workspaces = [
        "3"
        "4"
        "7"
        "8"
      ];
    }
  ];

  # turn off monitors after 15 minutes of inactivity
  services.swayidle = {
    events = [
      {
        # this gets triggered after sleep
        event = "after-resume";
        command = "${getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms on";
      }
      {
        # this system usually doesn't suspend
        # also turn on monitors on unlock
        event = "unlock";
        command = "${getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms on";
      }
    ];
    timeouts = [
      {
        timeout = 900;
        command = "${getExe' config.wayland.windowManager.hyprland.package "hyprctl"} dispatch dpms off";
      }
    ];
  };
}
