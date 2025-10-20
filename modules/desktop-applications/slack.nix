{
  flake.modules.homeManager.desktop-applications = {pkgs, ...}: {
    home.packages = [pkgs.slack];

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/slack" = "slack.desktop";
    };

    home.persistence."/persist".directories = [".config/Slack"];
  };
}
