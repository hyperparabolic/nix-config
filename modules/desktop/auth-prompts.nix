{
  flake.modules.nixos.desktop = {pkgs, ...}: {
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };

  flake.modules.homeManager.desktop = {pkgs, ...}: {
    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;
    home.packages = [pkgs.gcr];
  };
}
