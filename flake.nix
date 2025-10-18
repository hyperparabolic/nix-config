{
  nixConfig = {
    abort-on-warn = true;
    allow-import-from-derivation = false;
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
      url = "github:nix-community/lanzaboote/v0.4.2";
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

    walker = {
      url = "github:abenz1267/walker?ref=2.0.0";
      inputs = {
        elephant.url = "github:abenz1267/elephant?ref=2.0.0";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    systems,
    ...
  } @ inputs: let
    inherit (inputs.nixpkgs) lib;
    importNixFiles = dir:
      lib.filesystem.listFilesRecursive dir
      |> builtins.filter (f: lib.hasSuffix ".nix" (builtins.toString f));
  in
    flake-parts.lib.mkFlake {inherit inputs;} ({config, ...}: {
      imports =
        importNixFiles ./modules
        |> builtins.filter (f: !lib.hasPrefix "_" (builtins.toString f));

      flake = let
        inherit (self) outputs;
        lib = nixpkgs.lib // home-manager.lib;
        pkgsFor = lib.genAttrs (import systems) (
          system:
            import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
        );
        forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      in {
        inherit lib;
        nixosModules = import ./legacyModules/nixos;
        homeManagerModules = import ./legacyModules/home-manager;

        formatter = forEachSystem (pkgs: pkgs.alejandra);
        overlays = import ./overlays {inherit inputs outputs;};
        templates = import ./templates;

        # bootstrapping and repo tooling
        devShells = forEachSystem (pkgs: {
          default = pkgs.mkShell {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";
            buildInputs = with pkgs; [
              nix
              nix-diff
              git
              sops
              ssh-to-age
              gnupg
              age
              yq-go
              sbctl
            ];
          };
        });

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#oak'
        nixosConfigurations = let
          commonModules = with config.flake.modules.nixos; [
            core
          ];
        in {
          magnolia = lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./hosts/magnolia/configuration.nix] ++ commonModules;
          };
          oak = lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./hosts/oak/configuration.nix] ++ commonModules;
          };
          redbud = lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./hosts/redbud/configuration.nix] ++ commonModules;
          };
          warden = lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [./hosts/warden/configuration.nix] ++ commonModules;
          };

          # iso debugging / bootstrapping
          iso = lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [
              ./hosts/iso/configuration.nix
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ];
          };
        };
      };
    });
}
