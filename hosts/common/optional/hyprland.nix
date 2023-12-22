{
  imports = [
    ./gdm.nix
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
