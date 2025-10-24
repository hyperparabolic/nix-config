{
  flake.modules.nixos.core = {
    config,
    lib,
    pkgs,
    ...
  }: {
    system.autoUpgradeHydra = {
      enable = true;
      dates = lib.mkDefault "*-*-* 03:00:00 America/Chicago";
      settings = {
        healthChecks = {
          canaryHosts = [
            "redbud"
            "warden"
          ];
        };
        hydra = {
          instance = "https://hydra.oak.decent.id";
          project = "nix-config";
          jobset = "main";
          job = lib.mkDefault "hosts.${config.networking.hostName}";
        };
        nixos-rebuild = {
          operation = lib.mkDefault "boot";
          host = lib.mkDefault config.networking.hostName;
        };
      };
    };

    # I don't run nixos-rebuild as the root user when used manually,
    # ensure root user has trusted-settings.json
    systemd.services.ensure-trusted-settings = {
      description = "Ensure trusted-settings.json trusts oak";
      wantedBy = ["nixos-hydra-upgrade.service"];
      before = ["nixos-hydra-upgrade.service"];
      path = with pkgs; [
        jq
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        if [ ! -f /root/.local/share/nix/trusted-settings.json ]; then
            echo "{}" > /root/.local/share/nix/trusted-settings.json
        fi
        echo "$(jq '. += {"extra-substituters":{"https://cache.oak.decent.id":true},"extra-trusted-public-keys":{"cache.oak.decent.id:rf560rkaTPzpc8cg56bnPmmgqro8Lbn624jJSDF5YyY=":true}}' /root/.local/share/nix/trusted-settings.json)" > /root/.local/share/nix/trusted-settings.json
      '';
    };
  };
}
