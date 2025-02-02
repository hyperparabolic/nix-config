{
  outputs,
  inputs,
  ...
}: {
  # Each attribute here is an overlay function that is applied
  # globally to nixpkgs.overlays in system and home configs.

  # adds pkgs.stable for package versions from stable release`
  packages-stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };

  # adds packages in pkgs
  my-pkgs = final: _:
    import ../pkgs {pkgs = final;};
}
