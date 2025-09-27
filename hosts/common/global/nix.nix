{
  inputs,
  config,
  lib,
  ...
}: {
  nix = {
    settings = {
      substituters = [
        "https://cache.oak.decent.id"
      ];
      trusted-public-keys = [
        "cache.oak.decent.id:rf560rkaTPzpc8cg56bnPmmgqro8Lbn624jJSDF5YyY="
      ];
      trusted-users = ["root" "@wheel"];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };

    gc = {
      # delete generations older than a week once a week.
      # tune this down to a # of generations eventually.
      # just changing things a lot right now, manual cleanup until then.
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Adds each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent.
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  environment.persistence."/persist".directories = ["/root/.local/share/nix"];
}
