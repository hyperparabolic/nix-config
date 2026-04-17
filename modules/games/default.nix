{
  flake.modules.nixos.games = {...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  flake.modules.homeManager.games = {
    config,
    pkgs,
    ...
  }: {
    home = {
      packages = with pkgs; [
        (olympus.override {celesteWrapper = "steam-run";})
      ];
      persistence."${config.this.impermanence.dirs.games}".directories = [
        "Games"
        ".config/Olympus"
        ".factorio"
        ".local/share/Steam"
        ".local/share/Tabletop Simulator"
      ];
    };
  };
}
