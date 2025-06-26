{pkgs, ...}: {
  programs.starship = {
    enable = true;
    package = pkgs.stable.starship;
    enableFishIntegration = true;
    settings = {
    };
  };
}
