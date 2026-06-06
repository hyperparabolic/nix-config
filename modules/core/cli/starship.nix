{
  flake.modules.homeManager.core = {pkgs, ...}: {
    programs.starship = {
      enable = true;
      package = pkgs.starship;
      enableFishIntegration = true;
      settings = {
      };
    };

    stylix.targets.starship.enable = true;
  };
}
