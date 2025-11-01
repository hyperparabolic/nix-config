{
  flake.modules.homeManager.desktop-applications = {pkgs, ...}: {
    home.packages = with pkgs; [
      yubioath-flutter
    ];
  };
}
