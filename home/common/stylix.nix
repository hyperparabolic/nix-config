{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    image = ../../wallpaper/leaves.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    override = {
      base0A = "8aadf4";
      base0D = "eebb77";
    };

    cursor = {
      package = pkgs.apple-cursor;
      name = "macOS";
      size = 20;
    };

    fonts = {
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.nerd-fonts.fira-code;
      };
      sansSerif = {
        name = "Fira Sans";
        package = pkgs.fira;
      };
      serif = {
        name = "Fira Sans";
        package = pkgs.fira;
      };
    };

    iconTheme = {
      enable = true;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };

    targets = {
      bat.enable = true;
      dunst.enable = true;
      fish.enable = true;
      ghostty.enable = true;
      gtk.enable = true;
      hyprland.enable = true;
      hyprland.hyprpaper.enable = true;
      nixos-icons.enable = true;
      qt.enable = true;
      starship.enable = true;
      vesktop.enable = true;
      yazi.enable = true;
      zathura.enable = true;
    };
  };
}
