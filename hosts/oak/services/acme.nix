{config, ...}: {
  sops.secrets.dns-token = {
    sopsFile = ../secrets.yaml;
  };

  security.acme.certs = {
    "oak.decent.id" = {
      domain = "oak.decent.id";
      extraDomainNames = ["*.oak.decent.id"];
      dnsProvider = "digitalocean";
      dnsPropagationCheck = true;
      credentialsFile = config.sops.secrets.dns-token.path;
    };
  };

  # permit nginx to access certificate
  users.users.nginx.extraGroups = ["acme"];
}
