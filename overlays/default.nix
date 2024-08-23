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

  # adds pkgs.staging for newer than unstable packages
  packages-staging = final: _: {
    staging = inputs.nixpkgs-staging.legacyPackages.${final.system};
  };
}
