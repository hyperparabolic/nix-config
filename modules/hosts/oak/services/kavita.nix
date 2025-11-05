{
  flake.modules.nixos.hosts-oak = {config, ...}: {
    services = {
      kavita = {
        enable = true;
        tokenKeyFile = config.sops.secrets.kavita-token-key.path;
        settings = {
          IpAddresses = "127.0.0.1";
          Port = 26657;
        };
      };
      nginx.virtualHosts."books.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.kavita.settings.Port}";
        };
      };
    };

    sops.secrets.kavita-token-key = {
      sopsFile = ../../../../secrets/oak/secrets-kavita.yaml;
    };

    environment.persistence."/persist".directories = ["/var/lib/kavita"];
  };
}
