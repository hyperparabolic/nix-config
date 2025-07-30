{
  config,
  lib,
  ...
}: {
  system.autoUpgradeHydra = {
    enable = true;
    operation = lib.mkDefault "boot";
    host = lib.mkDefault config.networking.hostName;
    hydra = {
      instance = "https://hydra.oak.decent.id";
      project = "nix-config";
      jobset = "main";
      job = lib.mkDefault "hosts.${config.networking.hostName}";
    };
    healthChecks = {
      canaryHosts = [
        "redbud"
        "warden"
      ];
    };
    flags = [
      # root user doesn't always have trusted-settings.json, and I trust my repos
      "--accept-flake-config"
    ];
    dates = lib.mkDefault "*-*-* 03:00:00 America/Chicago";
  };
}
