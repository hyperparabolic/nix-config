{pkgs, ...}: {
  stylix = {
    enable = true;

    iconTheme = {
      enable = true;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };

    targets = {
      helix.enable = false;
    };
  };
}
