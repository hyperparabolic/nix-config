{ pkgs, ... }: {
  home.packages = [ pkgs.slack ];

  home.persistence = {
    "/persist/home/spencer".directories = [ ".config/Slack" ];
  };
}
