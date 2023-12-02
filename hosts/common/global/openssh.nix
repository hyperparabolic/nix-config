{ lib, config, ... }:
let
  # Keys are used here by sops-nix before impermanence can make
  # links. Must just use `/persist` keys directly if impermanence.
  hasPersistDir = config.environment.persistence ? "/persist";
in
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
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

  # TODO: preconfigure known hosts with programs.ssh from outputs
  # once I get around to adding more hosts and remote admin
}
