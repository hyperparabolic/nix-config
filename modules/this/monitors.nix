topLevel: let
  inherit (topLevel) lib;
  monitorOptions = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        example = "DP-1";
      };
      primary = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      width = lib.mkOption {
        type = lib.types.int;
        example = 1920;
      };
      height = lib.mkOption {
        type = lib.types.int;
        example = 1080;
      };
      refreshRate = lib.mkOption {
        type = lib.types.int;
        default = 60;
      };
      x = lib.mkOption {
        type = lib.types.int;
        default = 0;
      };
      y = lib.mkOption {
        type = lib.types.int;
        default = 0;
      };
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      transform = lib.mkOption {
        type = lib.types.int;
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
      workspaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Names of workspaces to initialize on the monitor
          on login.
        '';
      };
    };
  };
  monitorsOption = {
    type = lib.types.listOf monitorOptions;
    default = [];
  };
in {
  # Monitors are a meaningful concept in both nixos and home-manager configs
  # Define options in both places.
  flake.modules.nixos.this = {config, ...}: {
    options.this.monitors = lib.mkOption monitorsOption;

    config = {
      assertions = [
        {
          assertion =
            ((lib.length config.this.monitors) != 0)
            -> ((lib.length (lib.filter (m: m.primary) config.this.monitors)) == 1);
          message = "this.monitors: exactly one monitor must be set to primary";
        }
      ];
    };
  };

  flake.modules.homeManager.this = {config, ...}: {
    options.this.monitors = lib.mkOption monitorsOption;

    config = {
      assertions = [
        {
          assertion =
            ((lib.length config.this.monitors) != 0)
            -> ((lib.length (lib.filter (m: m.primary) config.this.monitors)) == 1);
          message = "this.monitors: exactly one monitor must be set to primary";
        }
      ];
    };
  };

  # Automagically copy nixos config to home-manager. Do not set properties
  # in both configs if this is imported.
  flake.modules.nixos.this-share-home = {config, ...}: {
    config = {
      assertions = [
        {
          assertion = (lib.length config.this.monitors) == (lib.length config.home-manager.users.spencer.this.monitors);
          message = "this.monitors: only define this.monitors in nixos module if using this-share-home";
        }
      ];

      home-manager = {
        sharedModules = with topLevel.config.flake.modules.homeManager; [
          this
          {
            this.monitors = config.this.monitors;
          }
        ];
      };
    };
  };
}
