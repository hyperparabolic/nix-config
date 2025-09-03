{
  config,
  lib,
  ...
}: {
  services = {
    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.oak.decent.id";
        listen-http = ":6839";
        behind-proxy = true;
        # leverage upstream for apns
        upstream-base-url = "https://ntfy.sh";
        auth-default-access = "deny-all";
        # users provisioned by env file
        auth-access = [
          "nix-ntfy:alert:rw"
          "nix-ntfy:notification:rw"
        ];
      };
    };
    nginx.virtualHosts."ntfy.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:${lib.lists.last (lib.strings.splitString ":" config.services.ntfy-sh.settings.listen-http)}";
        proxyWebsockets = true;
      };
    };
  };

  sops.secrets.ntfy-server = {
    sopsFile = ../secrets.yaml;
  };

  systemd.services.ntfy-sh = {
    serviceConfig.EnvironmentFile = config.sops.secrets.ntfy-server.path;
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/private/ntfy-sh"
    ];
  };
}
