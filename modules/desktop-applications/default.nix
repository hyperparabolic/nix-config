{
  flake.modules.homeManager.desktop-applications = {
    pkgs,
    lib,
    ...
  }: {
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

    systemd.user.services.wait-for-tray = let
      timeoutSeconds = 30;
      wait = pkgs.writeShellApplication {
        name = "wait-for-tray";
        runtimeInputs = with pkgs; [
          coreutils
          glib
        ];
        text = ''
          if ! timeout ${toString timeoutSeconds} gdbus wait --session org.kde.StatusNotifierWatcher; then
            echo "no status notifier host registered within ${toString timeoutSeconds}s, continuing anyway" >&2
          fi
        '';
      };
    in {
      Unit = {
        Description = "Wait for a status notifier host";
        PartOf = "graphical-session.target";
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe wait}";
      };
    };
  };
}
