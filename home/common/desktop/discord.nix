{pkgs, ...}: {
  home.packages = [pkgs.discord];

  home.persistence = {
    "/persist/home/spencer".directories = [".config/discord"];
  };
}
