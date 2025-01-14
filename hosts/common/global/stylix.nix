{
  config,
  pkgs,
  ...
}: {
  stylix = {
    enable = true;
    image = ../../../wallpaper/leaves.png;
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
      serif = config.stylix.fonts.sansSerif;
    };
  };
}
