{
  flake.modules.nixos.hosts-pando1 = {config, ...}: {
    sops.secrets.cf-dns-token = {
      sopsFile = ../../../../secrets/pando1/secrets-cf.yaml;
    };

    security.acme.certs = {
      "pando1.decent.id" = {
        domain = "pando1.decent.id";
        environmentFile = config.sops.secrets.cf-dns-token.path;
        extraDomainNames = ["*.pando1.decent.id"];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
      };
    };

    # permit nginx to access certificate
    users.users.nginx.extraGroups = ["acme"];
  };
}
