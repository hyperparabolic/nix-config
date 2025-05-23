{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./dunst.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./vanity.nix
    ./walker.nix
    ./wlsunset.nix
  ];

  home.packages = with pkgs; [
    # screenshot, screen recording, color picker
    grim
    grimblast
    slurp
    hyprpicker
    stable.wl-screenrec

    # clipboard and utils
    cliphist
    wl-clipboard

    # utils
    kdePackages.xwaylandvideobridge
    wlogout
  ];

  # wayland compat
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.mimeApps.enable = true;

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
