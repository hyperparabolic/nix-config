{ pkgs, config, ... }:
let
  ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = false;

    users.users = {
    spencer = {
      uid = 1000;
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
      ] ++ ifGroupExists[
        "pipewire"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBE1BVKz4604DdLKAb1DWcA8di6chBKSyE3qhpzoAdIE spencer@oak"
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

