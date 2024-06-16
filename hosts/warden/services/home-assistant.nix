{
  # deploying home-assistant as an OCI container
  # usb zigbee radio and config directory must exist
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      ports = [
        # web client
        "8123:8123"
        # sonos change events
        "1400:1400"
      ];
      volumes = [
        "/persist/home-assistant/config:/config"
        "/run/dbus:/run/dbus:ro"
        "/var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket"
      ];
      environment.TZ = "America/Chicago";
      image = "ghcr.io/home-assistant/home-assistant:2024.6";
      extraOptions = [
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"
      ];
    };
  };

  services.avahi = {
    enable = true;
    reflector = true;
  };

  networking.firewall.allowedTCPPorts = [
    # sonos change events
    1400
  ];

  services = {
    nginx.virtualHosts."ha.warden.decent.id" = {
      forceSSL = true;
      useACMEHost = "warden.decent.id";
      locations."/" = {
        proxyPass = "http://localhost:8123";
        proxyWebsockets = true;
      };
    };
  };
}
