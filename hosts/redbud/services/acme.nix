{config, ...}: {
  sops.secrets.dns-token = {
    sopsFile = ../secrets.yaml;
  };

  security.acme.certs = {
    "redbud.decent.id" = {
      domain = "redbud.decent.id";
      extraDomainNames = ["*.redbud.decent.id"];
      dnsProvider = "digitalocean";
      dnsPropagationCheck = true;
      credentialsFile = config.sops.secrets.dns-token.path;
    };
  };

  # permit nginx to access certificate
  users.users.nginx.extraGroups = ["acme"];
}
