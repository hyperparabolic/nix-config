{
  config,
  lib,
  ...
}: {
  # CLI only, sub config and service enablement in desktop
  hyperparabolic = {
    ntfy = {
      enable = true;
      environmentFile = config.sops.secrets.ntfy-client.path;
      settings = {
        default-host = "https://ntfy.oak.decent.id";
      };
    };
  };
  this = {
    zfs = {
      zedMailTo = "root"; # value doesn't matter, not using email, just needs to not be null;
      zedMailCommand = lib.getExe config.hyperparabolic.ntfy.package-notify;
      zedMailCommandOptions = "-";
    };
  };

  sops.secrets.ntfy-client = {
    sopsFile = ../../../secrets/common/secrets-ntfy.yaml;
    mode = "0440";
    owner = config.users.users.spencer.name;
    group = config.users.users.spencer.group;
  };
}
