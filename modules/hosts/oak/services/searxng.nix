{
  flake.modules.nixos.hosts-oak = {config, ...}: {
    services = {
      searx = {
        enable = true;
        environmentFile = config.sops.secrets.searxng.path;
        settings = {
          general = {
            instance_name = "decent search";
          };
          search = {
            autocomplete = "duckduckgo";
            default_lang = "en";
            safe_search = 0;
          };
          server = {
            port = 8888;
            bind_address = "0.0.0.0";
            image_proxy = true;
          };
          ui = {
            infinite_scroll = true;
            theme_args.simple_style = "dark";
          };
        };
      };

      nginx.virtualHosts."search.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          # port gets configured via web ui during setup
          proxyPass = "http://localhost:${toString config.services.searx.settings.server.port}";
        };
      };
    };

    sops.secrets.searxng = {
      sopsFile = ../../../../secrets/oak/secrets-searxng.yaml;
    };

    environment.persistence."/persist".directories = [
    ];
  };
}
