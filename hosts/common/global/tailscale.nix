{
  lib,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = lib.mkDefault "client";
    # temporarily roll back tailscale, tailscale networking is failing for 1.74.0 after 2 reboots
    package = pkgs.stable.tailscale;
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/tailscale"];
  };
}
