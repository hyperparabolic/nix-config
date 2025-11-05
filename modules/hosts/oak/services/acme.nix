{
  flake.modules.nixos.hosts-oak = {config, ...}: {
    sops.secrets.cf-dns-token = {
      sopsFile = ../../../../secrets/oak/secrets-cf.yaml;
    };

    security.acme.certs = {
      "oak.decent.id" = {
        domain = "oak.decent.id";
        environmentFile = config.sops.secrets.cf-dns-token.path;
        extraDomainNames = ["*.oak.decent.id"];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
      };
    };

    # permit nginx to access certificate
    users.users.nginx.extraGroups = ["acme"];
  };
}
