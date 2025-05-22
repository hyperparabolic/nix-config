{pkgs, ...}: {
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
    ./common/games
  ];

  monitors = [
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      primary = true;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
      ];
    }
  ];

  home.persistence = {
    "/persist/home/spencer" = {
      directories = [
        "src"
      ];
    };
  };

  # suspend after 6 minutes
  services.hypridle.settings.listener = [
    {
      timeout = 360;
      on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
    }
  ];
}
