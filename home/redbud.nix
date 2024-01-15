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

  # suspend after 6 minutes of inactivity
  services.swayidle = {
    timeouts = [
      {
        timeout = 360;
        command = "${getExe' config.systemd.package "systemctl"} suspend";
      }
    ];
  };
}
