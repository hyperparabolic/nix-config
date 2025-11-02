topLevel: let
  inherit (topLevel) lib;

  impermanenceOptions = {
    enable = lib.mkEnableOption "Enable impermanence for /persist persistence directory";
    enableRollback = lib.mkEnableOption "Enable impermanence rollback to blank snapshot on boot.";
  };
in {
  flake.modules.nixos.this = {...}: {
    options.this.impermanence = impermanenceOptions;
  };

  flake.modules.homeManager.this = {...}: {
    options.this.impermanence = impermanenceOptions;
  };

  flake.modules.nixos.this-share-home = {config, ...}: {
    config = {
      home-manager = {
        sharedModules = [
          {
            this.impermanence = config.this.impermanence;
          }
        ];
      };
    };
  };
}
