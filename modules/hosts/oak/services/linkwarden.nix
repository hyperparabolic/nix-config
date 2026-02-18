{
  flake.modules.nixos.hosts-oak = {config, ...}: {
    services = {
      linkwarden = {
        enable = true;
        host = "localhost";
        port = 6654;
        enableRegistration = false;
        environmentFile = config.sops.secrets.linkwarden.path;
        environment = {
          NEXTAUTH_URL = "https://links.oak.decent.id/api/v1/auth";
        };
      };
      nginx.virtualHosts."links.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          # port gets configured via web ui during setup
          proxyPass = "http://localhost:${toString config.services.linkwarden.port}";
        };
      };
    };

    sops.secrets.linkwarden = {
      sopsFile = ../../../../secrets/oak/secrets-linkwarden.yaml;
    };

    environment.persistence."/persist".directories = ["/var/lib/linkwarden"];
  };
}
