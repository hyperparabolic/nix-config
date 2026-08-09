let
  port = 28846;
in {
  flake.modules.nixos.hosts-oak = {...}: {
    services = {
      atuin = {
        inherit port;
        enable = true;
        openRegistration = false;
      };
      nginx.virtualHosts."atuin.oak.decent.id" = {
        forceSSL = true;
        useACMEHost = "oak.decent.id";
        locations."/" = {
          # port gets configured via web ui during setup
          proxyPass = "http://localhost:${toString port}";
        };
      };
    };
  };
}
