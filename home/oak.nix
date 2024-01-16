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
    }
    {
      name = "DP-1";
      width = 1920;
      height = 1080;
      x = 3840;
      # vertical orientation
      transform = 3;
    }
  ];
}
