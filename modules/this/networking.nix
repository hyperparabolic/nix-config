{lib, ...}: let
  networkingOptions = {
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The host's hostname";
    };
    hostId = lib.mkOption {
      type = lib.types.str;
      description = "The host's networking.hostId";
    };
    defaultNetworkInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The host's default hardware addressed network interface";
    };
    networkInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Network device names that should use DHCP";
    };
  };
in {
  flake.modules.nixos.this = {...}: {
    options.this.networking = networkingOptions;
  };

  flake.modules.homeManager.this = {...}: {
    options.this.networking = networkingOptions;
  };

  flake.modules.nixos.this-share-home = {config, ...}: {
    config.home-manager.sharedModules = [
      {
        this.networking = config.this.networking;
      }
    ];
  };
}
