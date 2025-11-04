{
  flake.modules.nixos.hosts-magnolia = {...}: {
    this.monitors = [
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
  };

  flake.modules.homeManager.hosts-magnolia = {pkgs, ...}: {
    home.persistence."/persist".directories = ["src"];

    # suspend after 6 minutes
    services.hypridle.settings.listener = [
      {
        timeout = 360;
        on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
