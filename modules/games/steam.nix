{
  flake.modules.nixos.games = {config, ...}: {
    programs.steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        args = let
          monitorArgs =
            if builtins.length config.this.monitors > 0
            then let
              primaryMonitor =
                builtins.elemAt (
                  config.this.monitors
                  |> builtins.filter (mon: mon.primary)
                )
                0;
            in [
              "--output-width ${builtins.toString primaryMonitor.width}"
              "--output-height ${builtins.toString primaryMonitor.height}"
              "--prefer-output ${primaryMonitor.name}"
            ]
            else [];
        in
          [
            "--adaptive-sync"
            "--expose-wayland"
            "--hdr-enabled"
            "--steam"
          ]
          ++ monitorArgs;
      };
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
