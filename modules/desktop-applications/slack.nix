{
  flake.modules.homeManager.desktop-applications = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.slack];

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/slack" = "slack.desktop";
    };

    home.persistence."/persist".directories = [".config/Slack"];

    systemd.user.services.slack = {
      Unit = {
        Description = "Slack";
        PartOf = "graphical-session.target";
        Requires = "wait-for-tray.service";
        After = [
          "graphical-session.target"
          "wait-for-tray.service"
        ];
      };
      Service.ExecStart = "${lib.getExe pkgs.slack}";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
