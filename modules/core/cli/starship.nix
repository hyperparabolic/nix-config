{
  flake.modules.homeManager.core = {pkgs, ...}: {
    programs.starship = {
      enable = true;
      package = pkgs.stable.starship;
      enableFishIntegration = true;
      settings = {
      };
    };

    stylix.targets.starship.enable = true;
  };
}
