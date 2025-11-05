{config, ...}: {
  services = {
    immich = {
      enable = true;
      database = {
        enableVectors = false;
        enableVectorChord = true;
      };
      mediaLocation = "/tank/immich";
      settings.server.externalDomain = "https://imgs.oak.decent.id";
    };
    nginx.virtualHosts."imgs.oak.decent.id" = {
      # allow large downloads / uploads
      extraConfig = ''
        client_max_body_size 1000M;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;
      '';
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.immich.port}";
        proxyWebsockets = true;
      };
    };
  };
}
