{
  imports = [
    ./gdm.nix
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
}
