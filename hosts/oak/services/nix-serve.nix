{ config, ... }:
{
  sops.secrets.cache-private-key = {
    sopsFile = ../secrets.yaml;
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets.cache-private-key.path;
    };
    nginx.virtualHosts."cache.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.nix-serve.port}";
      };
    };
  };
}
