{
  imports = [
    ./extensions.nix
    ./theme.nix
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "kitty.desktop"
        "firefox.desktop"
        "slack.desktop"
        "discord.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    
    "org/gnome/mutter" = {
      edge-tiling = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      # do not automatically suspend
      sleep-inactive-ac-type = "nothing";
    };

    # keybinds
    "org/gnome/mutter/keybindings" = {
      maximize = [ "<Control><Super>Up" ];
      minimize = [ "<Control><Super>Down" ];
      # unmaximize = [ "<Control><Super>Down" ];
      toggle-tiled-left = [ "<Control><Super>Left" ];
      toggle-tiled-right = [ "<Control><Super>Right" ];
      toggle-message-tray = [];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Control><Alt>l" ];
    };
  };

  home = {
    persistence = {
      "/persist/home/spencer" = {
        files = [
          ".config/monitors.xml"
        ];
      };
    };
  };
}
