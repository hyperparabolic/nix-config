{
  flake.modules.nixos.core = {
    inputs,
    outputs,
    lib,
    ...
  }: {
    nixpkgs = {
      # only global overlays
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
      };
    };

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
        cores = 8;
      };

      gc = {
        automatic = true;
        dates = "*-*-* 03:00:00 America/Chicago";
        options = "--delete-older-than 8d";
      };

      # Adds each flake input to nix registry
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    };

    # dedicated slice for nix-daemon resource management
    systemd = {
      slices."nix-daemon".sliceConfig = {
        CPUWeight = "10";
        MemoryMax = "80%";
        MemorySwapMax = "0";
        MemoryZSwapMax = "0";
      };
      services."nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";
        OOMPolicy = "continue";
        OOMScoreAdjust = 1000;
      };
    };

    environment.persistence."/persist".directories = ["/root/.local/share/nix"];
  };

  flake.modules.homeManager.core = {
    outputs,
    lib,
    pkgs,
    ...
  }: {
    home.sessionVariables.FLAKE = lib.mkDefault "~/.nix-config";

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
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
