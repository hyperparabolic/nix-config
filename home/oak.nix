{
  config,
  lib,
  ...
}: let
  inherit (lib) getExe';
in {
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
  ];

  # default audio device, and pipewire ids are not consistent, set defaults based on node.name
  # TODO: make this a module with input devices, output devices and volume levels for each?
  wayland.windowManager.hyprland.settings.exec-once = [
    "wpctl set-default $(pw-dump | jq '.[] | select(.info.props.\"node.name\" == \"alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.HiFi__scarlett2i_mono_in_USB_0_0__source\") | .id')"
    "wpctl set-volume $(pw-dump | jq '.[] | select(.info.props.\"node.name\" == \"alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.HiFi__hw_USB__sink\") | .id') 1.0"
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
