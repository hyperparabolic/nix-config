{inputs, ...}: {
  flake.overlays = {
    # lazily realized packages
    lazy-app = final: _: {
      lazy-app = inputs.lazy-apps.packages.${final.stdenv.hostPlatform.system}.lazy-app;
    };
  };
}
