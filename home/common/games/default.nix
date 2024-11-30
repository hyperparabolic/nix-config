{pkgs, ...}: {
  home = {
    packages = [
      pkgs.gamescope
    ];
    persistence = {
      "/persist/home/spencer" = {
        directories = [
          "Games"
          ".factorio"
          ".local/share/Steam"
          ".local/share/Tabletop Simulator"
        ];
      };
    };
  };
}
