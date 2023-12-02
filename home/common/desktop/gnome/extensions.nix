{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
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
    gnomeExtensions.forge
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
  ];
}
