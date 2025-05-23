{outputs, ...}: let
  hostnames = builtins.attrNames outputs.nixosConfigurations;
in {
  programs.ssh = {
    enable = true;
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
    };
  };

  home.persistence = {
    "/persist/home/spencer".directories = [".ssh"];
  };
}
