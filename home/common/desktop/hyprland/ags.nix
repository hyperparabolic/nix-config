{ inputs, pkgs, ... }: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = {
    enable = true;
    configDir = ./config/ags;
    package = inputs.ags.packages.x86_64-linux.agsWithTypes;
  };

  systemd.user.services = {
    ags = {
      Unit = {
        Description = "ags desktop widgets";
        PartOf = "graphical-session.target";
        Wants = [ "swayidle-status.service" "wlsunset-status.service" ];
      };
      Service = {
        Environment = "PATH=/run/current-system/sw/bin/";
        ExecStart = "${inputs.ags.packages.x86_64-linux.agsWithTypes}/bin/ags -b hypr";
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    # Integrating with dbus is hard, watching a file is easy and cheap.
    # The following servies report up / down statuses of other systemd
    # services to temporary files to allow monitoring of those serives
    # for UI based controls.
    swayidle-status = {
      Unit = {
        Description = "swayidle service status - file monitoring";
        PartOf = "swayidle.service";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils-full}/bin/echo 0 > /tmp/swayidle-status'";
        ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils-full}/bin/echo 1 > /tmp/swayidle-status'";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "swayidle.service" ];
    };
    wlsunset-status = {
      Unit = {
        Description = "wlsunset service status - file monitoring";
        PartOf = "wlsunset.service";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils-full}/bin/echo 0 > /tmp/wlsunset-status'";
        ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils-full}/bin/echo 1 > /tmp/wlsunset-status'";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "wlsunset.service" ];
    };
  };
}
