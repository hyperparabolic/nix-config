{pkgs, ...}: {
  home.packages = [
    pkgs.discord
    pkgs.vesktop
  ];

  stylix.targets.vesktop.enable = true;

  home.persistence = {
    "/persist/home/spencer".directories = [
      ".config/discord"
      ".config/vesktop"
    ];
  };
}
