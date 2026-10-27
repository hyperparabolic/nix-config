{
  flake.modules.nixos.hosts-oak = {
    inputs,
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.gradient.nixosModules.default
    ];

    services = {
      gradient = {
        enable = true;
        port = 47234;
        domain = "gradient.oak.decent.id";
        postgres.enable = true;
        worker.enable = true;
        eval.maxKeep = 3;
        secrets = {
          cryptFile = config.sops.secrets.gradient-crypt.path;
          jwtFile = config.sops.secrets.gradient-jwt.path;
        };
      };

      nginx.virtualHosts."gradient.oak.decent.id" = {
        # override module acme config
        enableACME = lib.mkForce false;
        useACMEHost = "oak.decent.id";
      };
    };

    sops.secrets.gradient-crypt = {
      sopsFile = ../../../../../secrets/oak/secrets-gradient.yaml;
      key = "gradient-crypt";
      owner = "gradient";
      mode = "0400";
    };
    sops.secrets.gradient-jwt = {
      sopsFile = ../../../../../secrets/oak/secrets-gradient.yaml;
      key = "gradient-jwt";
      owner = "gradient";
      mode = "0400";
    };

    environment.persistence."/persist".directories = ["/var/lib/gradient"];
  };
}
