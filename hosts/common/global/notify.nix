{
  config,
  lib,
  pkgs,
  ...
}: {
  # CLI only, sub config and service enablement in desktop
  hyperparabolic.ntfy = {
    enable = true;
    environmentFile = config.sops.secrets.ntfy-client.path;
    settings = {
      default-host = "https://ntfy.oak.decent.id";
    };
  };

  sops.secrets.ntfy-client = {
    sopsFile = ../../../secrets/common/secrets-ntfy.yaml;
    mode = "0440";
    owner = config.users.users.spencer.name;
    group = config.users.users.spencer.group;
  };

  # TODO: migrate zed notifications and remove secret
  sops.secrets.notify-provider-config = {
    sopsFile = ../../../secrets/common/secrets-zed.yaml;
    mode = "0440";
    owner = config.users.users.spencer.name;
    group = config.users.users.spencer.group;
  };

  # configure any native ntfy support services
  services = {
    zfs.zed = {
      settings = {
        ZED_NTFY_TOPIC = "notification";
        ZED_NTFY_URL = "https://ntfy.oak.decent.id";

        ZED_NOTIFY_INTERVAL_SECS = lib.mkDefault 3600;
        ZED_NOTIFY_VERBOSE = lib.mkDefault true;
        ZED_USE_ENCLOSURE_LEDS = lib.mkDefault true;
        ZED_SCRUB_AFTER_RESILVER = lib.mkDefault true;
      };
    };
  };
  systemd.services = {
    zfs-zed = {
      serviceConfig.EnvironmentFile = config.sops.secrets.zed-ntfy-env.path;
      path = with pkgs; [
        curl
      ];
    };
  };

  sops.secrets.zed-ntfy-env = {
    sopsFile = ../../../secrets/common/secrets-zed.yaml;
  };
}
