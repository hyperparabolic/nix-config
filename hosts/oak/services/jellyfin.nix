{
  # https reverse proxy setup for jellyfin
  services = {
    nginx.virtualHosts."jellyfin.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
        # port gets configured via web ui during setup
        proxyPass = "http://localhost:8096";
      };
    };
  };
}
