{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe';
in {
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
  ];

  monitors = [
    {
      name = "DP-1";
      width = 3840;
      height = 2160;
      refreshRate = 120;
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
      name = "HDMI-A-2";
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

  # Activate bind mount to share pipewire session with libvirt.
  # Ideally this should be a systemd unit, but user session mounts
  # are outside the beaten path and have permisssion issues I haven't
  # found a solution for.
  wayland.windowManager.hyprland.settings.exec-once = [
    "${lib.getExe (
      pkgs.writeShellScriptBin "share-pipewire-socket"
      /*
      bash
      */
      ''
        until [ -S /run/user/1000/pipewire-0 ]
        do
          sleep 1
        done
        mount /srv/win10/pipewire-0
      ''
    )}"
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
