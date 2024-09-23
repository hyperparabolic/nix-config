{lib, ...}: {
  networking.networkmanager.enable = lib.mkDefault true;
  services.resolved = {
    enable = true;
    fallbackDns = [];
  };
}
