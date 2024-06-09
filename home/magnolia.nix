{pkgs, ...}: {
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
  ];

  home.persistence = {
    "/persist/home/spencer" = {
      directories = [
        "src"
      ];
    };
  };

  # suspend after 6 minutes of inactivity
  services.swayidle = {
    timeouts = [
      {
        timeout = 360;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
