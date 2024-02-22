{pkgs, ...}: {
  imports = [
    ./greetd.nix
  ];

  programs = {
    dconf.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  services = {
    geoclue2.enable = true;
    gnome.gnome-keyring.enable = true;

    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

  networking.networkmanager.enable = true;

  security = {
    pam.services.swaylock.text = "auth include login";
    rtkit.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    configPackages = [pkgs.hyprland];
  };
}
