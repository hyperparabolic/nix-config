{
  flake.modules.nixos.hydra-builder = {
    outputs,
    config,
    ...
  }: let
    hydraPort = toString outputs.nixosConfigurations.oak.config.services.hydra.queueRunner.grpc.port;
  in {
    # TODO: multi-host, only supports local builds on oak for now
    services.hydra-builder = {
      enable = true;
      queueRunnerAddr = "http://[::1]:${hydraPort}";
      authorizationFile = config.sops.secrets.hydra-builder-token.path;
      settings = {
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      };
    };

    sops.secrets.hydra-builder-token = {
      sopsFile = ../../secrets/common/secrets-hydra.yaml;
      owner = "hydra-builder";
      mode = "0400";
      restartUnits = ["hydra-builder.service"];
    };
  };
}
