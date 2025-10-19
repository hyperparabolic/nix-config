{
  self,
  inputs,
  config,
  ...
}: {
  flake = let
    inherit (inputs.nixpkgs) lib;
    inherit (self) outputs;
  in {
    nixosConfigurations = let
      specialArgs = {inherit inputs outputs;};
    in {
      # TODO: generate programmatically from directory or module structure
      magnolia = lib.nixosSystem {
        inherit specialArgs;
        modules = config.flake.modules.nixos.hosts-magnolia.imports;
      };
      oak = lib.nixosSystem {
        inherit specialArgs;
        modules = config.flake.modules.nixos.hosts-oak.imports;
      };
      redbud = lib.nixosSystem {
        inherit specialArgs;
        modules = config.flake.modules.nixos.hosts-redbud.imports;
      };
      warden = lib.nixosSystem {
        inherit specialArgs;
        modules = config.flake.modules.nixos.hosts-warden.imports;
      };

      # iso debugging / bootstrapping
      iso = lib.nixosSystem {
        inherit specialArgs;
        modules =
          config.flake.modules.nixos.hosts-warden.imports
          ++ [
            "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ];
      };
    };
  };
}
