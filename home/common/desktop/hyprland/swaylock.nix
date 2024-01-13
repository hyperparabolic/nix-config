{ config, pkgs, ... }: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      font = config.fontProfiles.regular.family;
      fade-in = 5;
      color = "#000000ff";
    };
  };
}
