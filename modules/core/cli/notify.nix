{
  flake.modules.nixos.core = {config, ...}: {
    # CLI only, sub config and service enablement in desktop
    # `notify` and `alert` commands
    hyperparabolic = {
      ntfy = {
        enable = true;
        environmentFile = config.sops.secrets.ntfy-client.path;
        settings = {
          default-host = "https://ntfy.oak.decent.id";
        };
      };
    };

    sops.secrets.ntfy-client = {
      sopsFile = ../../../secrets/common/secrets-ntfy.yaml;
      mode = "0440";
      owner = config.users.users.spencer.name;
      group = config.users.users.spencer.group;
    };
  };
}
