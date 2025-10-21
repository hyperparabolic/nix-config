{pkgs, ...}: {
  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
      package = pkgs.stable.jellyfin;
    };
    nginx.virtualHosts."jellyfin.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
        # port gets configured via web ui during setup
        proxyPass = "http://localhost:8096";
      };
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/jellyfin"
    "/var/cache/jellyfin"
  ];
}
