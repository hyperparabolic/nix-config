{
  config,
  pkgs,
  ...
}: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      color = "#000000df";
      effect-pixelate = "15";
      fade-in = 5;
      font = config.fontProfiles.regular.family;
      screenshots = true;
    };
  };
}
