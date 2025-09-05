{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hyperparabolic.ntfy;
  settingsFormat = pkgs.formats.yaml {};
in {
  # ntfy script wrappers and user service
  options.hyperparabolic.ntfy = {
    enable = lib.mkEnableOption "Install ntfy package and wrapper scripts";

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Environment file (see {manpage}`systemd.exec(5)`
        "EnvironmentFile=" section for the syntax) to define service environment variables.
        This option may be used to safely include secrets without exposure in the nix store.

        This environment is sourced as a part of systemd user services and as a part of
        wrapper scripts. This should be provided by sops-nix, agenix or similar, and owned
        by the users group. Specify ntfy config as environment variables here.
      '';
    };

    settings = lib.mkOption {
      description = ''
        (YAML) settings file as described at https://docs.ntfy.sh/config/#config-options and
        https://docs.ntfy.sh/subscribe/cli/.
      '';
    };

    package-notify = lib.mkOption {
      type = lib.types.package;
      description = ''
        Wrapper script, publishes to notify topic with auth.
      '';
    };

    package-alert = lib.mkOption {
      type = lib.types.package;
      description = ''
        Wrapper script, publishes to alert topic with auth.
      '';
    };
  };

  config = let
    configuration = settingsFormat.generate "client.yml" cfg.settings;
    package-ntfy-notify = pkgs.writeShellApplication {
      name = "notify";
      runtimeInputs = with pkgs; [ntfy-sh];
      text = ''
        # shellcheck source=/dev/null
        source ${cfg.environmentFile}
        NTFY_TOPIC=notification ntfy publish -c ${configuration} -k "$NTFY_TOKEN" "$@"
      '';
    };
    package-ntfy-alert = pkgs.writeShellApplication {
      name = "alert";
      runtimeInputs = with pkgs; [ntfy-sh];
      text = ''
        # shellcheck source=/dev/null
        source ${cfg.environmentFile}
        NTFY_TOPIC=alert ntfy publish -c ${configuration} -k "$NTFY_TOKEN" "$@"
      '';
    };
  in
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        ntfy-sh
        package-ntfy-notify
        package-ntfy-alert
      ];
    };
}
