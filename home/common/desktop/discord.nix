{pkgs, ...}: {
  home.packages = [
    pkgs.discord
    pkgs.vesktop
  ];

  home.persistence = {
    "/persist/home/spencer".directories = [
      ".config/discord"
      ".config/vesktop"
    ];
  };
}
