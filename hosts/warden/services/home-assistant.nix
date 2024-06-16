{
  # deploying home-assistant as an OCI container
  # usb zigbee radio and config directory must exist
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [
        "/persist/home-assistant/config:/config"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "America/Chicago";
      image = "ghcr.io/home-assistant/home-assistant:2024.1";
      extraOptions = [
        "--network=host"
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
