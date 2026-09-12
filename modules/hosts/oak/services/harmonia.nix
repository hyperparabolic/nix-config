let
  port = 22243;
in {
  flake.modules.nixos.hosts-oak = {config, ...}: {
    sops.secrets.harmonia-private-key = {
      sopsFile = ../../../../secrets/oak/secrets-harmonia.yaml;
    };

    services = {
      harmonia = {
        cache = {
          enable = true;
          settings = {
            bind = "[::]:${toString port}";
          };
          signKeyPaths = [config.sops.secrets.harmonia-private-key.path];
        };
      };
      nginx.virtualHosts."cache.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
        };
      };
    };
  };
}
