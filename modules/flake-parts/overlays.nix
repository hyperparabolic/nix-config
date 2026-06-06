{inputs, ...}: {
  flake.overlays = {
    # lazily realized packages
    lazy-app = final: _: {
      lazy-app = inputs.lazy-apps.packages.${final.stdenv.hostPlatform.system}.lazy-app;
    };

    # TODO: remove after gcc15 breakages are ironed out
    packages-gcc14 = final: _: {
      gcc14 = inputs.nixpkgs-gcc14.legacyPackages.${final.stdenv.hostPlatform.system};
    };
  };
}
