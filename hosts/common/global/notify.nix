{ pkgs, config, ... }: {
  /*
    Sets up sending notifications via notify. This sends to whatever
    providers are specifed in the sops secrets file. Usage:

    notify -bulk -provider-config /run/secrets/notify-provider-config
  */
  environment.systemPackages = [
    pkgs.notify
  ];

  sops.secrets.notify-provider-config = {
    sopsFile = ../secrets.yaml;
    mode = "0440";
    owner = config.users.users.spencer.name;
    group = config.users.users.spencer.group;
  };
}
