{
  flake.modules.nixos.hosts-warden = {config, ...}: {
    services.prometheus.exporters.smokeping = {
      enable = true;
      hosts = [
        # comcast dns ips
        "75.75.75.75"
        "75.75.76.76"
      ];
    };
    # only expose metrics on vpn interface
    networking.firewall.interfaces."tailscale0" = {
      allowedTCPPorts = [config.services.prometheus.exporters.smokeping.port];
    };
  };
}
