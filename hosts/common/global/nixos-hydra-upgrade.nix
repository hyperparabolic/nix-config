{
  config,
  lib,
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
        args = [
          # root user doesn't always have trusted-settings.json, and I trust my repos
          "--accept-flake-config"
        ];
      };
    };
  };
}
