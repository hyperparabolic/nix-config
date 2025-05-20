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
      bat.enable = true;
      dunst.enable = true;
      ghostty.enable = true;
      gtk.enable = true;
      hyprland.enable = true;
      hyprland.hyprpaper.enable = true;
      qt.enable = true;
      starship.enable = true;
      swaylock.enable = true;
      vesktop.enable = true;
      yazi.enable = true;
      zathura.enable = true;
    };
  };
}
