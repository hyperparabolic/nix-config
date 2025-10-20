{config, ...}: {
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = ["systemd"];
  };
  # only expose metrics on vpn interface
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [config.services.prometheus.exporters.node.port];
  };
}
