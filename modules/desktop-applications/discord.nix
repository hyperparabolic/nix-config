{
  flake.modules.homeManager.desktop-applications = {pkgs, ...}: {
    home.packages = [
      pkgs.discord
      pkgs.vesktop
    ];

    stylix.targets.vesktop.enable = true;

    home.persistence."/persist".directories = [
      ".config/discord"
      ".config/vesktop"
    ];
  };
}
