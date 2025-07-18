{config, ...}: {
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.oak.decent.id";
      notificationSender = "hydra@localhost";
      listenHost = "localhost";
      useSubstitutes = true;
      buildMachinesFiles = ["/etc/nix/machines"];
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

  # populates /etc/nix/machines, used above
  nix.buildMachines = [
    {
      hostName = "localhost";
      protocol = null;
      systems = ["x86_64-linux" "aarch64-linux"];
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 8;
    }
  ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/hydra"
    ];
  };
}
