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
  hosts =
    builtins.readDir "${self}/modules/hosts"
    |> lib.filterAttrs (_n: v: v == "directory")
    |> builtins.attrNames;
in {
  flake.nixosConfigurations = lib.genAttrs hosts (name:
    lib.nixosSystem {
      inherit specialArgs;
      modules = config.flake.modules.nixos."${hostModulePrefix}${name}".imports;
    });
}
