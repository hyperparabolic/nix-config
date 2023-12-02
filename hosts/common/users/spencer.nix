{ pkgs, config, ... }: {
  users.mutableUsers = false;

    users.users = {
    spencer = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuxIDOWjjLv2g/Pnr0/V+NtlvFfGadJq5Cxsb06lQ1X spencer@sloth"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHbkshQXiKpkxbyYe+H6duIbCblGSws5jwP//g8zhq7bWCVQSPWo8I7lJbmqlaqUINnjQWTZXMlKuH6g7NihsUY= spencer@dugong"
      ];
      hashedPasswordFile = config.sops.secrets.spencer-password.path;
    };
  };

  sops.secrets.spencer-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.spencer = import ../../../home/${config.networking.hostName}.nix;
}

