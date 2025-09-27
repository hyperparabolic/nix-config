{config, ...}: {
  services = {
    loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3100;
        auth_enabled = false;

        analytics = {
          reporting_enabled = false;
        };

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore = {
              store = "inmemory";
            };
          };
          replication_factor = 1;
          path_prefix = "/var/lib/loki";
        };

        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsbd-shipper-active";
            cache_location = "/var/lib/loki/tsbd-shipper-cache";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };
      };
    };

    nginx.virtualHosts."logs.redbud.decent.id" = {
      forceSSL = true;
      useACMEHost = "redbud.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
      };
    };
  };

  environment.persistence."/persist".directories = ["/var/lib/loki"];
}
