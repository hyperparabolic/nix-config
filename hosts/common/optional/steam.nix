{
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--adaptive-sync"
        "--expose-wayland"
        "--hdr-enabled"
        "--steam"
      ];
    };
    localNetworkGameTransfers.openFirewall = true;
  };
}
