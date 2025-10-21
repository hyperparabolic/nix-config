{config, ...}: {
  sops.secrets.cf-dns-token = {
    sopsFile = ../../../secrets/redbud/secrets-cf.yaml;
  };

  security.acme.certs = {
    "redbud.decent.id" = {
      domain = "redbud.decent.id";
      environmentFile = config.sops.secrets.cf-dns-token.path;
      extraDomainNames = ["*.redbud.decent.id"];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
    };
  };

  # permit nginx to access certificate
  users.users.nginx.extraGroups = ["acme"];
}
