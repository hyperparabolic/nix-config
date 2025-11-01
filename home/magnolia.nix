{pkgs, ...}: {
  imports = [
    ./common/desktop/hyprland
  ];

  home.persistence."/persist".directories = ["src"];

  # suspend after 6 minutes
  services.hypridle.settings.listener = [
    {
      timeout = 360;
      on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
    }
  ];
}
