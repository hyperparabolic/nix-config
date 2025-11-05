{
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = true;
    };
    # conflicts with adguard dns server
    resolved.enable = false;
    nginx.virtualHosts."adguard.warden.decent.id" = {
      forceSSL = true;
      useACMEHost = "warden.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    };
  };

  environment.persistence."/persist".directories = ["/var/lib/private/AdGuardHome/"];
}
