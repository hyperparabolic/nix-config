{
  inputs,
  pkgs,
  lib,
  ...
}: let
  agsPackages = inputs.ags.packages.${pkgs.system};
  vanityPackages = inputs.vanity.packages.${pkgs.system};
in {
  home.packages = [
    agsPackages.default
    vanityPackages.default
  ];

  systemd.user.services = {
    vanity = {
      Unit = {
        Description = "vanity desktop shell";
        PartOf = "graphical-session.target";
      };
      Service = {
        Environment = [
          "PATH=/run/current-system/sw/bin/"
          "HOME=%h"
        ];
        ExecStart = "${lib.getExe vanityPackages.default}";
      };
      Install.WantedBy = ["hyprland-session.target"];
    };
  };

  wayland.windowManager.hyprland.settings = {
    bind = lib.mkAfter [
      "$MOD, E, exec, ags request -i 'vanity' 'menu:toggle'"
    ];
  };
}
