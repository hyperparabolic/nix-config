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
    
    "org/gnome/mutter" = {
      edge-tiling = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      # do not automatically suspend
      sleep-inactive-ac-type = "nothing";
    };
  };
}
