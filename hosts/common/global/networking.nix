{
  networking.networkmanager.enable = true;
  services.resolved = {
    enable = true;
    fallbackDns = [];
  };
}
