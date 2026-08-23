{
  flake.modules.nixos.core = {lib, ...}: {
    networking = {
      networkmanager.enable = true;
      useNetworkd = true;
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
