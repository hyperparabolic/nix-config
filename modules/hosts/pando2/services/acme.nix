{
  flake.modules.nixos.hosts-pando2 = {config, ...}: {
    sops.secrets.cf-dns-token = {
      sopsFile = ../../../../secrets/pando2/secrets-cf.yaml;
    };

    security.acme.certs = {
      "pando2.decent.id" = {
        domain = "pando2.decent.id";
        environmentFile = config.sops.secrets.cf-dns-token.path;
        extraDomainNames = ["*.pando2.decent.id"];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
      };
    };

    # permit nginx to access certificate
    users.users.nginx.extraGroups = ["acme"];
  };
}
