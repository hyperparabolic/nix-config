{
  inputs,
  config,
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
    # I haven't found a great way to subscribe to systemd service state without polling.
    # This template creates a file ~/.local/state/%i-state that can be watched with a
    # file watcher, avoiding polling.
    "file-state@" = {
      Unit = {
        Description = "%i service state file monitoring";
        PartOf = "%i.service";
      };
      Service = let
        bash = "${lib.getExe pkgs.bash}";
        echo = "${lib.getExe' pkgs.coreutils-full "echo"}";
      in {
        Type = "oneshot";
        ExecStart = "${bash} -c '${echo} 0 > ${config.home.homeDirectory}/.local/state/%i-state'";
        ExecStop = "${bash} -c '${echo} 1 > ${config.home.homeDirectory}/.local/state/%i-state'";
        RemainAfterExit = true;
      };
    };
    vanity = {
      Unit = {
        Description = "vanity desktop shell";
        PartOf = "graphical-session.target";
        After = "wayland-wm@Hyprland.service";
        Wants = ["file-state@wlsunset.service"];
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
    wlsunset.Unit.Wants = ["file-state@wlsunset.service"];
  };

  wayland.windowManager.hyprland.settings = {
    bind = lib.mkAfter [
      "$MOD, E, exec, vanity --toggle-menu"
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
