{
  config,
  lib,
  outputs,
  ...
}: let
  hosts = lib.attrNames outputs.nixosConfigurations;
in {
  services = {
    prometheus = {
      enable = true;
      extraFlags = [
        "--storage.tsdb.retention.size 100GB"
      ];
      scrapeConfigs = [
        {
          job_name = "grafana";
          scheme = "https";
          static_configs = [{targets = ["dash.redbud.decent.id"];}];
        }
        {
          job_name = "prometheus";
          scheme = "https";
          static_configs = [{targets = ["metrics.redbud.decent.id"];}];
        }
        {
          job_name = "hosts";
          scheme = "http";
          static_configs =
            map (hostname: {
              labels.instance = hostname;
              targets = ["${hostname}:${toString config.services.prometheus.exporters.node.port}"];
            })
            hosts;
        }
      ];
    };
    nginx.virtualHosts."metrics.redbud.decent.id" = {
      forceSSL = true;
      useACMEHost = "redbud.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.prometheus.port}";
      };
    };
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/prometheus2"];
  };
}
