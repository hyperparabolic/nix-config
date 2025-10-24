{
  flake.modules.nixos.core = {
    inputs,
    config,
    ...
  }: let
    # utils, select ed25519 key from openssh config
    isEd25519 = k: k.type == "ed25519";
    getKeyPath = k: k.path;
    keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
  in {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      age.sshKeyPaths = map getKeyPath keys;
    };
  };
}
