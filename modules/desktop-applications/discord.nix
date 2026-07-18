{
  flake.modules.homeManager.desktop-applications = {pkgs, ...}: {
    home.packages = [
      pkgs.discord
    ];

    home.persistence."/persist".directories = [
      ".config/discord"
    ];
  };
}
