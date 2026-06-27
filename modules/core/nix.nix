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
      };

      gc = {
        automatic = true;
        dates = "*-*-* 03:00:00 America/Chicago";
        options = "--delete-older-than 8d";
      };

      # Adds each flake input to nix registry
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    };

    # Limit memory use for nix daemon processes. This permits short bursts, but
    # will kill processes if >20s above limit memory use in build processes.
    systemd = {
      slices."nix-daemon".sliceConfig = {
        ManagedOOMMemoryPressure = "kill";
        ManagedOOMMemoryPressureLimit = "50%";
      };
      services."nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";

        # Kernel level backup, strongly prefer killing nix daemon processes
        # just in case there is other heavy memory use concurrent to builds.
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
