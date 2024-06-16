{
  # deploying home-assistant as an OCI container
  # usb zigbee radio and config directory must exist
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      ports = [
        "8123:8123"
      ];
      volumes = [
        "/persist/home-assistant/config:/config"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "America/Chicago";
      image = "ghcr.io/home-assistant/home-assistant:2024.6";
      extraOptions = [
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"
      ];
    };
  };

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
