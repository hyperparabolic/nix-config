{
  flake.modules.nixos.tailscale-exit-node = {...}: {
    services.tailscale = {
      useRoutingFeatures = "both";
    };
  };
}
