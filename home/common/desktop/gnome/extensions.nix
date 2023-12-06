{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "espresso@coadmunkee.github.com"
        "forge@jmmaranan.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = true;
      click-action = "focus-or-previews";
      dock-position = "LEFT";
      scroll-action = "cycle-windows";
      show-show-apps-button = false;
    };

    "org/gnome/shell/extensions/forge/keybindings" = {
      # disable annoying 1/3 snaps
      window-snap-center = [];
      window-snap-one-third-left = [];
      window-snap-one-third-right = [];
      window-snap-two-third-left = [];
      window-snap-two-third-right = [];
    };

    # system monitor
    "org/gnome/shell/extensions/vitals" = {
      alphabetize = false;
      hot-sensors = [
        "_system_load_1m_"
        "__network-rx_max__"
        "_memory_usage_"
        "_memory_swap_"
        "__temperature_max__"
      ];
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.espresso
    gnomeExtensions.forge
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
  ];
}
