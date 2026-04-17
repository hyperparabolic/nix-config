{
  flake.modules.nixos.games = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      gamescope-wsi
      steamcmd
    ];

    programs = {
      gamescope = {
        enable = true;
      };
      steam = {
        enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
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
                "--output-width ${toString primaryMonitor.width}"
                "--output-height ${toString primaryMonitor.height}"
                "--prefer-output ${primaryMonitor.name}"
                "--nested-refresh ${toString primaryMonitor.refreshRate}"
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
  };
}
