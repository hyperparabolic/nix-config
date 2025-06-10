{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    yubikey-touch-detector
  ];

  systemd.user.services = {
    yubikey-touch-detector = {
      Unit = {
        Description = "YubiKey touch detector";
        PartOf = "graphical-session.target";
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.yubikey-touch-detector} --libnotify --dbus";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
