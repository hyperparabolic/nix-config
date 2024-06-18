{config, ...}: {
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = "dash.redbud.decent.id";
        };
      };
      provision = {
        enable = true;

        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "https://metrics.redbud.decent.id";
              isDefault = true;
            }
          ];
        };
      };
    };

    nginx.virtualHosts."dash.redbud.decent.id" = {
      forceSSL = true;
      useACMEHost = "redbud.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.grafana.settings.server.http_port}";
      };
    };
  };
}
