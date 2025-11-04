{
  flake.modules.nixos.games = {...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  flake.modules.homeManager.games = {pkgs, ...}: {
    home = {
      packages = [
        pkgs.gamescope
      ];
      persistence."/persist".directories = [
        "Games"
        ".factorio"
        ".local/share/Steam"
        ".local/share/Tabletop Simulator"
      ];
    };
  };
}
