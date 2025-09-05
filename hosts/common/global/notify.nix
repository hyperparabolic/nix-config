{config, ...}: {
  # CLI only, sub config and service enablement in desktop
  hyperparabolic.ntfy = {
    enable = true;
    environmentFile = config.sops.secrets.ntfy-client.path;
    settings = {
      default-host = "https://ntfy.decent.id";
    };
  };

  sops.secrets.ntfy-client = {
    sopsFile = ../secrets.yaml;
    mode = "0440";
    owner = config.users.users.spencer.name;
    group = config.users.users.spencer.group;
  };

  # TODO: migrate zed notifications and remove secret
  sops.secrets.notify-provider-config = {
    sopsFile = ../secrets.yaml;
    mode = "0440";
    owner = config.users.users.spencer.name;
    group = config.users.users.spencer.group;
  };
}
