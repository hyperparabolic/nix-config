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
        nix_build = {
          operation = lib.mkDefault "boot";
          host = lib.mkDefault config.networking.hostName;
        };
      };
    };

    # I don't run nix as the root user when used manually,
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
        echo "$(jq '. += {"abort-on-warn":{"true":true},"allow-import-from-derivation":{"false":true},"extra-experimental-features":{"pipe-operators":true},"extra-substituters":{"https://cache.oak.decent.id":true},"extra-trusted-public-keys":{"cache.oak.decent.id-1:/OgEHwbOG0pcEErkH/1t5F910BCKiZ2c3zAOr8cq440=":true}}' /root/.local/share/nix/trusted-settings.json)" > /root/.local/share/nix/trusted-settings.json
      '';
    };
  };
}
