{pkgs, ...}: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      effect-pixelate = "15";
      effect-vignette = "0.3:0";
      screenshots = true;
    };
  };
}
