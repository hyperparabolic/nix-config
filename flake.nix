{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

    pkgsPlatform = nixpkgs.lib.genAttrs supportedSystems (system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    });

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # bootstrapping and repo tooling
    devShells = forAllSystems (system:
      let
        pkgs = pkgsPlatform.${system};
      in {
        default = pkgs.mkShell {
          NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
          buildInputs = with pkgs; [
            nix
            git
            sops
            ssh-to-age
            gnupg
            age
          ];
        };
    });

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#oak'
    nixosConfigurations = {
      oak = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/oak/configuration.nix ];
      };
      redbud = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/redbud/configuration.nix ];
      };
    };

    # standalone home-manager is kinda borked with my config?
    # maybe dig at this later, but just gets invoked via nxios-rebuild
    # for now

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#spencer@oak'
    #homeConfigurations = {
    #  "spencer@oak" = home-manager.lib.homeManagerConfiguration {
    #    pkgs = pkgsPlatform.x86_64-linux;
    #    extraSpecialArgs = {inherit inputs outputs;};
    #    modules = [./home/oak.nix];
    #  };
    #};
  };
}

