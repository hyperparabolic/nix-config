{
  flake.modules.nixos.core = {
    config,
    lib,
    ...
  }: {
    networking = {
      hostName = config.this.networking.hostname;
      networkmanager.enable = true;
      useNetworkd = true;
      interfaces =
        config.this.networking.networkInterfaces
        |> lib.map (interface: {
          "${interface}".useDHCP = true;
        })
        |> lib.mkMerge;
    };
    services.resolved = {
      enable = lib.mkDefault true;
      settings = {
        Resolve.FallbackDNS = [];
      };
    };
    systemd.network = {
      enable = true;
      wait-online.enable = lib.mkDefault false;
    };
  };
}
