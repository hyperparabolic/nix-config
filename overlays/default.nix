{
  inputs,
  ...
}: {
  # Each attribute here is an overlay function that is applied
  # globally to nixpkgs.overlays in system and home configs.

  # lazily realized packages
  lazy-app = final: _: {
    lazy-app = inputs.lazy-apps.packages.${final.system}.lazy-app;
  };

  # adds pkgs.stable for package versions from stable release`
  packages-stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };
}
