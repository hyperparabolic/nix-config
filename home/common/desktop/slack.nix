{pkgs, ...}: {
  home.packages = [pkgs.slack];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/slack" = "slack.desktop";
  };

  home.persistence = {
    "/persist/home/spencer".directories = [".config/Slack"];
  };
}
