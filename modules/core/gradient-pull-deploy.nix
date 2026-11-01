{
  flake.modules.nixos.core = {
    config,
    lib,
    ...
  }: {
    sops.secrets.gradient-deploy-key = {
      sopsFile = ../../secrets/common/secrets-gradient.yaml;
      key = "gradient-deploy-key";
      owner = "gradient";
      mode = "0400";
    };

    system.gradient-deploy = {
      enable = true;
      server = "https://gradient.oak.decent.id";
      task = "nix-config/build-hosts";
      apiKeyFile = config.sops.secrets.gradient-deploy-key.path;
      dates = lib.mkDefault "*-*-* 03:00:00 America/Chicago";
      randomizedDelaySec = "3600";
    };
  };
}
