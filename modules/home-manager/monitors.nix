{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "DP-1";
        };
        primary = mkOption {
          type = types.bool;
          default = false;
        };
        width = mkOption {
          type = types.int;
          example = 1920;
        };
        height = mkOption {
          type = types.int;
          example = 1080;
        };
        refreshRate = mkOption {
          type = types.int;
          default = 60;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
        };
        transform = mkOption {
          type = types.int;
          default = 0;
          description = ''
            normal (no transforms) -> 0
            90 degrees -> 1
            180 degrees -> 2
            270 degrees -> 3
            flipped -> 4
            flipped + 90 degrees -> 5
            flipped + 180 degrees -> 6
            flipped + 270 degrees -> 7
          '';
        };
        workspaces = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Names of workspaces to initialize on the monitor
            on login.
          '';
        };
      };
    });
    default = [];
  };
  config = {
    assertions = [
      {
        assertion =
          ((lib.length config.monitors) != 0)
          -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ];
  };
}
