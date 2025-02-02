{pkgs, ...}: {
  imports = [
    ./greetd.nix
    ./plymouth.nix
  ];

  programs = {
    dconf.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  services = {
    geoclue2.enable = true;
    gnome.gnome-keyring.enable = true;

    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

  security = {
    pam.services.swaylock.text = "auth include login";
    polkit.enable = true;
    rtkit.enable = true;
  };

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

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-termfilechooser
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    # configPackages = [pkgs.hyprland];
    config = {
      hyprland.default = [
        "termfilechooser"
        "gtk"
        "hyprland"
      ];
    };
  };
}
