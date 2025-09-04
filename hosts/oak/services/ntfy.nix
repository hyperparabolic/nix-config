{
  config,
  lib,
  ...
}: {
  # This doesn't quite work how I imagined it would. A few notes:
  #
  # Cloudflare manages a *.decent.id certificate and terminates TLS at
  # *.cfargotunnel.com.
  #
  # DNS resolution is not going how I expect at ingress. ntfy.oak.decent.id
  # is being mangled somewhere, and oak.decent.id seems(?) to be served
  # instead. oak.decent.id also does exist, but more like a hostname, and
  # nothing is really supposed to be served there to browsers. I'm not
  # positive, but I think the hostname might be getting lost here entirely.
  #
  # Instead, having nginx listen on a different port just for ntfy, and
  # not relying on hostnames for routing at tunnel ingress. nginx could
  # just be skipped for this specific case, but I want a pattern that
  # works and is generic for any hosts on this network served through this
  # tunnel.
  #
  # Might debug and take another pass on this later, but for now it works.
  security.acme.certs = {
    "ntfy.decent.id" = {
      domain = "ntfy.decent.id";
      environmentFile = config.sops.secrets.cf-dns-token.path;
      extraDomainNames = ["ntfy.oak.decent.id"];
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
    };
  };

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
          "nix-ntfy:notification:rw"
        ];
        smtp-server-listen = ":1025";
        smtp-server-domain = "ntfy.decent.id";
      };
    };
    cloudflared.tunnels."11019326-9f73-4021-95c4-03bcd7e6389e" = {
      ingress = {
        "ntfy.decent.id" = "https://ntfy.oak.decent.id:6838";
      };
    };
    nginx.virtualHosts."ntfy.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "ntfy.decent.id";
      listen = [
        {
          addr = "0.0.0.0";
          port = 6838;
          ssl = true;
        }
      ];
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

  # smtp server for email sent notifications is only accessible by vpn or on loopback
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      (lib.strings.toInt
        (lib.lists.last
          (lib.strings.splitString ":" config.services.ntfy-sh.settings.smtp-server-listen)))
    ];
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/private/ntfy-sh"
    ];
  };
}
