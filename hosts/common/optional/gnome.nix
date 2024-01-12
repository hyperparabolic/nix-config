{ pkgs, ... }: {
  imports = [
    ./gdm.nix
  ];

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome = {
        enable = true;
      };
    };
    geoclue2.enable = true;
    gnome.games.enable = true;
  };
  networking.networkmanager.enable = true;

  environment.variables = {
    # firefox wayland support
    MOZ_ENABLE_WAYLAND = "1";
  };

  environment.gnome.excludePackages = (with pkgs; [
    gedit
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-music
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

  # TODO: revisit this, it's not right after changing video cards
  # gdm monitors config
  # environment.persistence = {
  #   "/persist" = {
  #     files = [
  #       "/run/gdm/.config/monitors.xml"
  #     ];
  #   };
  # };
}
