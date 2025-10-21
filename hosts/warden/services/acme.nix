{config, ...}: {
  sops.secrets.cf-dns-token = {
    sopsFile = ../../../secrets/warden/secrets-cf.yaml;
  };

  security.acme.certs = {
    "warden.decent.id" = {
      domain = "warden.decent.id";
      environmentFile = config.sops.secrets.cf-dns-token.path;
      extraDomainNames = ["*.warden.decent.id"];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
    };
  };

  # permit nginx to access certificate
  users.users.nginx.extraGroups = ["acme"];
}
