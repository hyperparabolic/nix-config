{
  flake.modules.nixos.hosts-oak = {
    inputs,
    config,
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
        reverseProxy.nginx = {
          enable = true;
          useACMEHost = "oak.decent.id";
          manageTls = false;
        };
        secrets = {
          cryptFile = config.sops.secrets.gradient-crypt.path;
          jwtFile = config.sops.secrets.gradient-jwt.path;
        };
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
