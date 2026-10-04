{
  flake.modules.homeManager.desktop-applications = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.discord
    ];

    home.persistence."/persist".directories = [
      ".config/discord"
    ];

    systemd.user.services.discord = {
      Unit = {
        Description = "Discord";
        PartOf = "graphical-session.target";
        Requires = "wait-for-tray.service";
        After = [
          "graphical-session.target"
          "wait-for-tray.service"
        ];
      };
      Service.ExecStart = "${lib.getExe pkgs.discord}";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
