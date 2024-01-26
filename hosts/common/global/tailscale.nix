{ lib, ... }: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall = {
    checkReversePath = "loose";
    # needed for nat traversal setup
    allowedUDPPorts = [ 41641 ];
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/tailscale" ];
  };
}
