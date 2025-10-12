{
  config,
  lib,
  ...
}: {
  services = {
    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.decent.id";
        listen-http = ":6839";
        # just disable web interface entirely. Hopefully take the edge
        # off scraping / probing traffic.
        web-root = "disable";
        behind-proxy = true;
        # leverage upstream for apns
        upstream-base-url = "https://ntfy.sh";
        auth-default-access = "deny-all";
        # users provisioned by env file
        auth-access = [
          "nix-ntfy:alert:rw"
          "nix-ntfy:email:rw"
          "nix-ntfy:notification:rw"
          "webhook:alert:wo"
          "webhook:notification:wo"
          # email topic is blocked by cloudflared / nginx config, can only send
          # to this topic with localhost access or via VPN accessible SMTP publishing
          "*:email:wo"
        ];
        smtp-server-listen = ":1025";
        smtp-server-domain = "ntfy.decent.id";
      };
    };
    nginx.virtualHosts."ntfy.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations = {
        # email topic publishing blocked
        "/email" = {
          return = "404";
        };
        # email topic read permitted
        "~ /email/(json|sse|raw|ws)" = {
          proxyPass = "http://localhost:${lib.lists.last (lib.strings.splitString ":" config.services.ntfy-sh.settings.listen-http)}";
          proxyWebsockets = true;
        };
        "/" = {
          proxyPass = "http://localhost:${lib.lists.last (lib.strings.splitString ":" config.services.ntfy-sh.settings.listen-http)}";
          proxyWebsockets = true;
        };
      };
    };
  };

  sops.secrets.ntfy-server = {
    sopsFile = ../secrets.yaml;
  };

  systemd.services.ntfy-sh = {
    serviceConfig.EnvironmentFile = config.sops.secrets.ntfy-server.path;
  };

  # smtp server for email sent notifications is only accessible by vpn or on loopback
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      (lib.strings.toInt
        (lib.lists.last
          (lib.strings.splitString ":" config.services.ntfy-sh.settings.smtp-server-listen)))
    ];
  };

  environment.persistence."/persist".directories = ["/var/lib/private/ntfy-sh"];
}
