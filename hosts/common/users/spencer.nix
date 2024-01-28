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
        "networkmanager"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvhQ4MIVZBmADR24mXGlbZZHq4tr/sYK79dyTPpVPvq7Nukvw0dstfuyoSsnz9aqFMgMGMfVn9C4Y09TcW9bclg9A1MbAGbi6rXHz8pv4i+27docFXJI2kMkOU7CnDAdleEJxBx+EA05wtKoVEKA3zQoUAEQ1O+CKttYX4ZzYW0AWdRtVcfE9a6zKRGljR/suZzxBUkIILxPnfHLFQ9HySMa4KQcP1IPQ5op2wl/xBGTrnXwTzvtBnlYCWiZmTxs9kFlXyuZx69L4RaYIhguo5CTGXid3uelAHas/l223VzALKMWrwBGt6Hz/4OEcz5WSgNbqIEf+S3i1LpDomG3KKMH1k9iToG9ikkO0vCqIVKHyWTTckQD6GBMezIyi/5S/6VkOzEPAxImV155XKDm9OeMOzN1I/vmhlD8ARizNZjIGg1ThgxRp98agnEBtqt4hh3cgqC9Bf6e3oylIhlNYPW9J0akcX3NidwAfIhXUqGjs8ScoZC2OcmEclR9cgzg46kWqZJScACsmrD+sXZGNiD0gJNpmNSZvEZX9DcVwvv0rsUghdXWQmNGxbZDhAgzuhGdykBUEwFORbR08l44VHCL8E0fMYZDAjlAWqUbUMHBuudy5AfWAPpp8OJ8teybL/+tIv3KS4/tuvPDWaqz8dBXmcfAdEMdMpqt9qla3ECQ== cardno:7849559"
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

