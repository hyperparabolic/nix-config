{ pkgs, ... }: {
  imports = [
    ./common
    ./common/desktop
    ./common/desktop/hyprland
  ];

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
