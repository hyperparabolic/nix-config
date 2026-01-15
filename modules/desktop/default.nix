{
  flake.modules.nixos.desktop = {...}: {
    hardware.graphics.enable = true;

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  flake.modules.homeManager.desktop = {pkgs, ...}: {
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
    ];

    # wayland compat
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
    };

    services.hyprpaper.settings.splash = false;

    stylix = {
      image = pkgs.fetchurl {
        name = "leaves.png";
        url = "https://i.imgur.com/9EAejof.png";
        hash = "sha256-k3nLKUCmjrUAkM7NJev/LNSCC5Kx6jWBXyngAb/MZXU=";
      };
      targets = {
        gtk.enable = true;
        hyprland.enable = true;
        hyprland.hyprpaper.enable = true;
        nixos-icons.enable = true;
        qt.enable = true;
      };
    };

    xdg.mimeApps.enable = true;
  };
}
