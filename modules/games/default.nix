{
  flake.modules.nixos.games = {...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  flake.modules.homeManager.games = {config, ...}: {
    home = {
      persistence."${config.this.impermanence.dirs.games}".directories = [
        "Games"
        ".factorio"
        ".local/share/Steam"
        ".local/share/Tabletop Simulator"
      ];
    };
  };
}
