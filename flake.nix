{
  nixConfig = {
    abort-on-warn = true;
    allow-import-from-derivation = false;
    extra-experimental-features = "pipe-operators";
    extra-substituters = ["https://cache.oak.decent.id"];
    extra-trusted-public-keys = ["cache.oak.decent.id:rf560rkaTPzpc8cg56bnPmmgqro8Lbn624jJSDF5YyY="];
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default-linux";

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence/home-manager-v2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazy-apps = {
      url = "sourcehut:~rycee/lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-hydra-upgrade = {
      url = "github:hyperparabolic/nixos-hydra-upgrade";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vanity.url = "github:hyperparabolic/vanity";

    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs = {
        elephant.follows = "elephant";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {flake-parts, ...} @ inputs: let
    inherit (inputs.nixpkgs) lib;
    importNixFiles = dir:
      lib.filesystem.listFilesRecursive dir
      |> builtins.filter (f: lib.hasSuffix ".nix" (builtins.toString f));
  in
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports =
        importNixFiles ./modules
        |> builtins.filter (f: !lib.hasInfix "/_" (builtins.toString f));
    });
}
