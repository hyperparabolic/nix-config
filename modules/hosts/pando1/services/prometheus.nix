{
  flake.modules.nixos.hosts-pando1 = {
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
            job_name = "hosts";
            scheme = "http";
            static_configs =
              map (hostname: {
                labels.instance = hostname;
                targets = ["${hostname}:${toString config.services.prometheus.exporters.node.port}"];
              })
              hosts;
          }
          {
            job_name = "hydra-notify";
            scheme = "http";
            static_configs = [{targets = ["oak:9199"];}];
          }
          {
            job_name = "hydra-queue-runner";
            scheme = "http";
            static_configs = [{targets = ["oak:9198"];}];
          }
          {
            job_name = "grafana";
            scheme = "https";
            static_configs = [{targets = ["dash.pando1.decent.id"];}];
          }
          {
            job_name = "prometheus";
            scheme = "https";
            static_configs = [{targets = ["metrics.pando1.decent.id"];}];
          }
          {
            job_name = "smokeping";
            scheme = "http";
            static_configs = [{targets = ["warden:${toString config.services.prometheus.exporters.smokeping.port}"];}];
          }
        ];
      };
      nginx.virtualHosts."metrics.pando1.decent.id" = {
        forceSSL = true;
        useACMEHost = "pando1.decent.id";
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.prometheus.port}";
        };
      };
    };

    environment.persistence."/persist".directories = ["/var/lib/prometheus2"];
  };
}
