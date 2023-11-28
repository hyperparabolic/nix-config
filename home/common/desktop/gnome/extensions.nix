{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
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
  };

  home.packages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
  ];
}