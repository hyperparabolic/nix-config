{
  flake.modules.nixos.core = {
    outputs,
    lib,
    config,
    ...
  }: let
    inherit (config.networking) hostName;
    excludeHosts = ["iso"];
    hosts = lib.attrsets.filterAttrs (n: _v: !builtins.elem n excludeHosts) outputs.nixosConfigurations;
    pubKey = host: ../../secrets/${host}/ssh_host_ed25519_key.pub;

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

    security.pam = {
      rssh = {
        enable = true;
        settings = {
          # loglevel = "info";
        };
      };
      services.sudo.rssh = true;
    };
  };

  flake.modules.homeManager.core = {outputs, ...}: let
    hostnames = builtins.attrNames outputs.nixosConfigurations;
  in {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        net = {
          host = builtins.concatStringsSep " " hostnames;
          forwardAgent = true;
          remoteForwards = [
            {
              # static socket locations set up in gpg.nix
              bind.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
              host.address = ''/%d/.gnupg-sockets/S.gpg-agent'';
            }

            {
              # static socket locations set up in gpg.nix
              bind.address = ''/%d/.gnupg-sockets/S.gpg-agent.ssh'';
              host.address = ''/%d/.gnupg-sockets/S.gpg-agent.ssh'';
            }
          ];
        };
        "*" = {
          addKeysToAgent = "no";
        };
      };
    };

    home.persistence."/persist".directories = [".ssh"];
  };
}
