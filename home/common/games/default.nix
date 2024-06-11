{pkgs, ...}: {
  imports = [
    ./steam.nix
  ];

  home = {
    packages = [
      pkgs.gamescope
    ];
    persistence = {
      "/persist/home/spencer" = {
        directories = [
          "Games"
        ];
      };
    };
  };
}
