{config, ...}: {
  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
  };
  networking.firewall.allowedTCPPorts = [80 443];
}
