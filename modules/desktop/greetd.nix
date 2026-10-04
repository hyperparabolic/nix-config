{
  flake.modules.nixos.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    settingsFormat = pkgs.formats.toml {};
    tuigreetConfig = settingsFormat.generate "tuigreet.toml" config.this.tuigreet.settings;
  in {
    options.this.tuigreet.settings = lib.mkOption {
      type = lib.types.submodule {freeformType = settingsFormat.type;};
      default = {};
      description = ''
        tuigreet settings, rendered as TOML
        see https://github.com/tuigreet/tuigreet#toml-configuration
      '';
    };

    config = {
      this.tuigreet.settings = {
        display.show_time = true;
        session.sessions_dirs = ["${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"];
        remember = {
          username = true;
          user_session = true;
        };
      };

      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${lib.getExe pkgs.tuigreet} --config ${tuigreetConfig}";
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
  };
}
