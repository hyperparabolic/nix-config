{
  flake.modules.nixos.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          # tuigreet with selectable sessions
          command = "${lib.getExe pkgs.tuigreet} --time --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
          user = "greeter";
        };
      };
    };

    systemd.services.initialize-tuigreet-cache = {
      description = "Initialize tuigreet cache";
      wantedBy = ["greetd.service"];
      before = ["greetd.service"];
      path = with pkgs; [
        coreutils-full
      ];
      serviceConfig.Type = "oneshot";
      script =
        /*
        bash
        */
        ''
          TMPDIR=$(mktemp -d)
          echo "spencer" > "$TMPDIR"/lastuser
          echo "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/hyprland-uwsm.desktop" > "$TMPDIR"/lastsession-path-spencer
          install -g greeter -o greeter -m 0755 -d /var/cache/tuigreet
          install -g greeter -o greeter -m 0644 -t /var/cache/tuigreet "$TMPDIR"/lastuser "$TMPDIR"/lastsession-path-spencer
          rm -rf "$TMPDIR"
        '';
    };
  };
}
