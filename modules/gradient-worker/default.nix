let
  workerHostnames = ["oak" "pando1" "pando2"];

  # obviously not a standard uuid, but good enough
  hashToUuid = hash: let
    p1 = builtins.substring 0 8 hash;
    p2 = builtins.substring 8 4 hash;
    p3 = builtins.substring 12 4 hash;
    p4 = builtins.substring 16 4 hash;
    p5 = builtins.substring 20 12 hash;
  in "${p1}-${p2}-${p3}-${p4}-${p5}";

  # stable "uuids" from hostname
  hostnameToUuid = hostname:
    "gradient-worker:${hostname}"
    |> builtins.hashString "sha256"
    |> hashToUuid;
in {
  # Builders just share tokens and peer files, and all peer files
  # are permitted to work on all projects. There is not a meaningful
  # trust boundary between them here since they all build software
  # running on oak, and I own all projects.
  flake.modules.nixos.hosts-oak = {config, ...}: {
    sops.secrets = {
      gradient-builder-key = {
        sopsFile = ../../secrets/common/secrets-gradient.yaml;
        key = "gradient-builder-key";
        owner = "gradient";
        mode = "0400";
      };
    };

    services.gradient = {
      # just register oak as non-local to share config
      localWorker = false;
      proto.public = true;
      state = {
        workers =
          workerHostnames
          |> map (hostname: {
            name = hostname;
            value = {
              worker_id = hostnameToUuid hostname;
              projects = builtins.attrNames config.services.gradient.state.projects;
              token_file = config.sops.secrets.gradient-builder-key.path;
            };
          })
          |> builtins.listToAttrs;
      };
    };
  };

  flake.modules.nixos.gradient-worker = {
    inputs,
    config,
    ...
  }: {
    imports = [
      inputs.gradient.nixosModules.default
    ];

    sops.secrets = {
      gradient-peers-file = {
        sopsFile = ../../secrets/common/secrets-gradient.yaml;
        key = "gradient-peers-file";
        owner = "gradient-worker";
        mode = "0400";
      };
    };

    services.gradient.worker = {
      enable = true;
      id = hostnameToUuid config.this.networking.hostname;
      serverUrl = "wss://gradient.oak.decent.id/proto";
      peersFile = config.sops.secrets.gradient-peers-file.path;
      build.metrics = true;
    };
  };
}
