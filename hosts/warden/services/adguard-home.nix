{config, ...}: {
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = true;
    };
    nginx.virtualHosts."adguard.warden.decent.id" = {
      forceSSL = true;
      useACMEHost = "warden.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.adguardhome.settings.bind_port}";
      };
    };
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/private/AdGuardHome/"
    ];
  };
}
