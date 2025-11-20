{
  self,
  inputs,
  config,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (self) outputs;
  specialArgs = {inherit inputs outputs;};
  hostModulePrefix = "hosts-";
in {
  flake.nixosConfigurations =
    config.flake.modules.nixos
    |> lib.filterAttrs (name: _: lib.hasPrefix hostModulePrefix name)
    |> lib.mapAttrs' (name: module: {
      name = lib.removePrefix hostModulePrefix name;
      value = lib.nixosSystem {
        inherit specialArgs;
        modules = [module];
      };
    });
}
