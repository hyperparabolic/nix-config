{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    base16Scheme = {
      name = "Catppuccin Macchiato (Yellow)";
      author = "https://github.com/catppuccin/catppuccin";
      base00 = "24273a";
      base01 = "1e2030";
      base02 = "363a4f";
      base03 = "494d64";
      base04 = "5b6078";
      base05 = "cad3f5";
      base06 = "f4dbd6";
      base07 = "b7bdf8";
      base08 = "ed8796";
      base09 = "f5a97f";
      base0A = "8aadf4";
      base0B = "a6da95";
      base0C = "8bd5ca";
      base0D = "eebb77";
      base0E = "c6a0f6";
      base0F = "f0c6c6";
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
  };
}
