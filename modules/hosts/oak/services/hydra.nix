{
  flake.modules.nixos.hosts-oak = {
    config,
    pkgs,
    ...
  }: {
    services = {
      hydra = {
        package = pkgs.hydra;
        enable = true;
        hydraURL = "https://hydra.oak.decent.id";
        notificationSender = "hydra@localhost";
        listenHost = "localhost";
        useSubstitutes = true;
        smtpHost = "localhost";
        extraConfig = ''
          email_notification = 1
        '';
        extraEnv = {
          EMAIL_SENDER_TRANSPORT_port = "1025";
        };
        queueRunner = {
          settings = {
            tokenPaths = [
              config.sops.secrets.hydra-queue-runner-token.path
            ];
          };
        };
      };
      nginx.virtualHosts = {
        "hydra.oak.decent.id" = {
          forceSSL = true;
          useACMEHost = "oak.decent.id";
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString config.services.hydra.port}";
            };
          };
        };
      };
    };

    networking.firewall.interfaces."tailscale0" = {
      allowedTCPPorts = [
      ];
    };

    sops.secrets.hydra-queue-runner-token = {
      sopsFile = ../../../../secrets/common/secrets-hydra.yaml;
      key = "hydra-builder-token";
      owner = "hydra-queue-runner";
      mode = "0400";
      reloadUnits = ["hydra-queue-runner.service"];
    };

    environment.persistence."/persist".directories = ["/var/lib/hydra"];
  };
}
