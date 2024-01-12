{ inputs, ... }: {
  imports = [
    inputs.anyrun.homeManagerModules.default
    ./anyrun.nix
  ];
}
