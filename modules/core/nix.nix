{
  flake.modules.nixos.core = {
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
        experimental-features = "nix-command flakes pipe-operators";
        auto-optimise-store = true;
      };

      gc = {
        automatic = true;
        dates = "*-*-* 03:00:00 America/Chicago";
        options = "--delete-older-than 8d";
      };

      # Adds each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

      # Additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent.
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };

    environment.persistence."/persist".directories = ["/root/.local/share/nix"];
  };

  flake.modules.homeManager.core = {
    outputs,
    lib,
    pkgs,
    ...
  }: {
    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        allowUnfreePredicate = _: true;
      };
    };

    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        warn-dirty = false;
      };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    home.persistence."/persist".directories = [
      ".local/share/nix"
      ".nix-config"
    ];
  };
}
