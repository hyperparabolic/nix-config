{
  flake.modules.nixos.user-spencer = {
    pkgs,
    config,
    ...
  }: let
    ifGroupExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    users.users = {
      spencer = {
        uid = 1000;
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups =
          [
            "wheel"
          ]
          ++ ifGroupExists [
            "gamemode"
            "networkmanager"
            "pipewire"
          ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBu4zfqpuW/Uip7IYIqL6nDAhA0Lf+/qzLQ8LqGU+IE cardno:33_095_352"
        ];
        hashedPasswordFile = config.sops.secrets.spencer-password.path;
      };
    };

    sops.secrets.spencer-password = {
      sopsFile = ../../../secrets/common/secrets-spencer.yaml;
      neededForUsers = true;
    };

    home-manager.users.spencer = import ../../../home/${config.networking.hostName}.nix;
  };

  flake.modules.homeManager.user-spencer = {...}: {
    home = {
      username = "spencer";
      homeDirectory = "/home/spencer";
    };
  };
}
