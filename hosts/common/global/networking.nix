{lib, ...}: {
  networking.networkmanager.enable = true;
  services.resolved = {
    enable = lib.mkDefault true;
    fallbackDns = [];
  };
}
