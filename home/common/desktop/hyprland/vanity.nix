{
  inputs,
  pkgs,
  lib,
  ...
}: let
  agsPackages = inputs.ags.packages.${pkgs.system};
  vanityPackages = inputs.vanity.packages.${pkgs.system};
in {
  home.packages = with pkgs; [
    agsPackages.default
    vanityPackages.default

    # glycin deps
    bubblewrap
    glycin-loaders
    lcms2
    libseccomp
  ];

  systemd.user.services = {
    vanity = {
      Unit = {
        Description = "vanity desktop shell";
        PartOf = "graphical-session.target";
        After = "wayland-wm@Hyprland.service";
      };
      Service = {
        Environment = [
          "PATH=/run/current-system/sw/bin/"
          "HOME=%h"
        ];
        ExecStart = "${lib.getExe vanityPackages.default}";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };

  wayland.windowManager.hyprland.settings = {
    bind = lib.mkAfter [
      "$MOD, E, exec, ags request -i 'vanity' 'menu:toggle'"
    ];
  };

  # desktop file needed for geoclue
  xdg.desktopEntries = {
    "com.github.hyperparabolic.vanity" = {
      name = "Vanity Shell";
      exec = "${lib.getExe vanityPackages.default}";
      terminal = false;
      type = "Application";
      categories = ["Utility"];
      noDisplay = true;
    };
  };
}
