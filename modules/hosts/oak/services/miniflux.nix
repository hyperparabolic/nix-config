{
  flake.modules.nixos.hosts-oak = {config, ...}: let
    listenAddress = "localhost:24762";
  in {
    sops.secrets.miniflux-admin = {
      sopsFile = ../../../../secrets/oak/secrets-miniflux.yaml;
    };

    services = {
      miniflux = {
        enable = true;
        adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
        # automatically created database is fine unless I move it to another host
        createDatabaseLocally = true;
        config = {
          # keep in sync with proxyPass below
          LISTEN_ADDR = listenAddress;
          BASE_URL = "https://rss.oak.decent.id/";
          HTTPS = 1;
        };
      };
      nginx.virtualHosts."rss.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          proxyPass = "http://${listenAddress}";
        };
      };
    };
  };
}
