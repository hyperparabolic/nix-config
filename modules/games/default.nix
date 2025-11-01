{pkgs, ...}: {
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
}
