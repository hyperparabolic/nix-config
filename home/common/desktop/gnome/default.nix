{
  imports = [
    ./extensions.nix
    ./theme.nix
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "org.gnome.Console.desktop"
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
      unmaximize = [ "<Control><Super>Down" ];
      toggle-tiled-left = [ "<Control><Super>Left" ];
      toggle-tiled-right = [ "<Control><Super>Right" ];
    };
  };
}
