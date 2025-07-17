{config, ...}: {
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.oak.decent.id";
      notificationSender = "hydra@localhost";
      listenHost = "localhost";
      useSubstitutes = true;
      # standalone for first swing, TODO: add local kvm build support, add redbud builder
      buildMachinesFiles = [];
    };
    nginx.virtualHosts."hydra.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
        # port gets configured via web ui during setup
        proxyPass = "http://localhost:${toString config.services.hydra.port}";
      };
    };
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/hydra"
    ];
  };
}
