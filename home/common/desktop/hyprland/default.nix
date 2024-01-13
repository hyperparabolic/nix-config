{ inputs, pkgs, ... }: {
  imports = [
    inputs.anyrun.homeManagerModules.default
    ./anyrun.nix
    ./dunst.nix
    ./hyprland.nix
    ./swayidle.nix
    ./swaylock.nix
    ./swayosd.nix
  ];

  home.packages = with pkgs; [
    hyprpicker
    wl-clipboard
    wl-screenrec
    wlogout
    wlsunset
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
