{
  outputs,
  lib,
  config,
  ...
}: let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../${host}/ssh_host_ed25519_key.pub;

  # Keys are used here by sops-nix before impermanence can make
  # links. Must just use `/persist` keys directly if impermanence.
  hasPersistDir = config.hyperparabolic.impermanence.enable;
in {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      # agent forwarding management
      # remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };

    hostKeys = [
      {
        path = "${lib.optionalString hasPersistDir "/persist"}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${lib.optionalString hasPersistDir "/persist"}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  programs.ssh = {
    # iterate hosts to generate knownHosts
    knownHosts =
      builtins.mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        # Alias for localhost if it's the same host
        extraHostNames = lib.optional (name == hostName) "localhost";
      })
      hosts;
  };
}
