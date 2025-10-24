{
  flake.modules.homeManager.desktop-applications = {pkgs, ...}: {
    home.packages = with pkgs;
      [
        # wayland xrandr tools
        gnome-randr
        wlr-randr

        # pipewire graph editor
        qpwgraph

        vlc
      ]
      # less frequently used apps are realized lazily
      ++ lib.map lazy-app.override [
        {pkg = d-spy;}
      ];
  };
}
