{
  services = {
    xserver = {
      enable = true;
      desktopManager.pantheon.enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.pantheon.enable = true;
      };
    };
    pantheon.apps.enable = true;
    geoclue2.enable = true;
  };
  programs = {
    pantheon-tweaks.enable = true;
  };

  networking.networkmanager.enable = false;
  services.avahi.enable = false;
}
