{config, ...}: {
  services.cloudflared = {
    enable = true;
    tunnels."11019326-9f73-4021-95c4-03bcd7e6389e" = {
      credentialsFile = config.sops.secrets.cf-tunnel-cred.path;
      default = "http_status:404";
      ingress = {
        "ntfy.decent.id" = {
          # only route to authenticated topics
          path = "^/(notification|alert)";
          service = config.services.nginx.virtualHosts."ntfy.oak.decent.id".locations."/".proxyPass;
        };
      };
    };
    certificateFile = config.sops.secrets.cf-tunnel-cert.path;
  };

  sops.secrets = {
    cf-tunnel-cert = {
      sopsFile = ../../../secrets/oak/secrets-cf.yaml;
    };
    cf-tunnel-cred = {
      sopsFile = ../../../secrets/oak/secrets-cf.yaml;
    };
  };
}
