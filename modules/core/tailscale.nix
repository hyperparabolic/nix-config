{lib, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "client";
  };

  environment.persistence."/persist".directories = ["/var/lib/tailscale"];
}
