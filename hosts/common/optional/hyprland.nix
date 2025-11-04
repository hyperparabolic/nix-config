{
  programs = {
    dconf.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  services = {
    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };
  };
}
