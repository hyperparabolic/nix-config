{ pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome = {
        enable = true;
      };
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    geoclue2.enable = true;
    gnome.games.enable = true;
  };
  networking.networkmanager.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-music
    gedit
    epiphany
    geary
    gnome-characters
    yelp
    gnome-contacts
    gnome-initial-setup
  ]);
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];
}