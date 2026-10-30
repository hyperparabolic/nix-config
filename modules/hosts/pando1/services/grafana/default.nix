{
  flake.modules.nixos.hosts-pando1 = {config, ...}: {
    sops.secrets = {
      grafana-spencer-password = {
        sopsFile = ../../../../../secrets/pando1/secrets-grafana.yaml;
        owner = "grafana";
      };
      grafana-secret-key = {
        sopsFile = ../../../../../secrets/pando1/secrets-grafana.yaml;
        owner = "grafana";
      };
    };

    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            domain = "dash.pando1.decent.id";
          };
          analytics = {
            check_for_updates = false;
            check_for_plugin_updates = false;
            reporting_enabled = false;
          };
          security = {
            admin_user = "spencer";
            admin_password = "$__file{${config.sops.secrets.grafana-spencer-password.path}}";
            cookie_secure = true;
            secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
          };
        };
        provision = {
          enable = true;
          dashboards.settings.providers = [
            {
              options.path = ./dashboards;
            }
          ];
          datasources.settings = {
            apiVersion = 1;
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "https://metrics.pando1.decent.id";
                # pinned so provisioned dashboards can reference it
                uid = "PBFA97CFB590B2093";
                isDefault = true;
              }
              {
                name = "Loki";
                type = "loki";
                access = "proxy";
                url = "https://logs.pando1.decent.id";
              }
            ];
          };
        };
      };

      nginx.virtualHosts."dash.pando1.decent.id" = {
        forceSSL = true;
        useACMEHost = "pando1.decent.id";
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
