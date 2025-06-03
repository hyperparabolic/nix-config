{config, ...}: {
  sops.secrets.dns-token = {
    sopsFile = ../secrets.yaml;
  };

  security.acme.certs = {
    "warden.decent.id" = {
      domain = "warden.decent.id";
      extraDomainNames = ["*.warden.decent.id"];
      dnsProvider = "digitalocean";
      dnsPropagationCheck = true;
      credentialsFile = config.sops.secrets.dns-token.path;
    };
  };

  # permit nginx to access certificate
  users.users.nginx.extraGroups = ["acme"];
}
