{
  description = "Your new nix config";

  nixConfig = {
    extra-substituters = ["https://cache.oak.decent.id"];
    extra-trusted-public-keys = ["cache.oak.decent.id:rf560rkaTPzpc8cg56bnPmmgqro8Lbn624jJSDF5YyY="];
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default-linux";

    ags.url = "github:Aylur/ags";

    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    vanity.url = "github:hyperparabolic/vanity";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    systems,
    ...
  } @ inputs: let
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
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    overlays = import ./overlays {inherit inputs outputs;};

    # bootstrapping and repo tooling
    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes";
        buildInputs = with pkgs; [
          nix
          git
          sops
          ssh-to-age
          gnupg
          age
          yq-go
        ];
      };
    });

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#oak'
    nixosConfigurations = {
      magnolia = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/magnolia/configuration.nix];
      };
      oak = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/oak/configuration.nix];
      };
      redbud = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/redbud/configuration.nix];
      };
      warden = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/warden/configuration.nix];
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
}
