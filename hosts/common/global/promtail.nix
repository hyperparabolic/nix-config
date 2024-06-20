{config, ...}: {
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3101;
        grpc_listen_port = 0;
      };

      clients = [
        {
          url = "https://logs.redbud.decent.id/loki/api/v1/push";
        }
      ];

      positions = {
        filename = "/tmp/positions.yaml";
      };

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
        }
      ];
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [config.services.promtail.configuration.server.http_listen_port];
  };
}
