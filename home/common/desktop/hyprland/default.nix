{ inputs, pkgs, ... }: {
  imports = [
    ./ags.nix
    ./anyrun.nix
    ./dunst.nix
    ./hyprland.nix
    ./swayidle.nix
    ./swaylock.nix
    ./swayosd.nix
    ./theme.nix
    ./wlsunset.nix
  ];

  home.packages = with pkgs; [
    # screenshot, screen recording, color picker
    grim
    grimblast
    slurp
    gpick
    hyprpicker
    wl-screenrec

    # clipboard and utils
    cliphist
    wl-clipboard

    # utils
    swaybg
    xwaylandvideobridge
    wlogout
  ];

  # wayland compat
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };
}
