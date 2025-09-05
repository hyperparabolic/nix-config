{config, ...}: {
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.oak.decent.id";
      notificationSender = "hydra@localhost";
      listenHost = "localhost";
      useSubstitutes = true;
      buildMachinesFiles = ["/etc/nix/machines"];
      smtpHost = "localhost:1025";
      extraConfig = ''
        queue_runner_metrics_address = 0.0.0.0:9198
        <hydra_notify>
          <prometheus>
            listen_address = 0.0.0.0
            port = 9199
          </prometheus>
        </hydra_notify>
      '';
    };
    nginx.virtualHosts."hydra.oak.decent.id" = {
      forceSSL = true;
      useACMEHost = "oak.decent.id";
      locations."/" = {
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

  # expose metrics to tailscale interface only
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      9198 # hydra-queue-runner
      9199 # hydra-notify
    ];
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/hydra"
    ];
  };
}
