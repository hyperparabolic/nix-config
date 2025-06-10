{
  outputs,
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

  # upstream version with dbus support
  # TODO: remove once in nixpkgs-unstable
  # https://github.com/NixOS/nixpkgs/pull/414115
  yubikey-touch-detector-dbus = final: prev: {
    yubikey-touch-detector = prev.yubikey-touch-detector.overrideAttrs (old: {
      version = "1.13.0";

      src = final.fetchFromGitHub {
        owner = "maximbaz";
        repo = "yubikey-touch-detector";
        rev = "1.13.0";
        hash = "sha256-aHR/y8rAKS+dMvRdB3oAmOiI7hTA6qlF4Z05OjwYOO4=";
      };
      vendorHash = "sha256-oHEcpu3QvcVC/YCtGtP7nNT9++BSU8BPT5pf8NdLrOo=";
    });
  };
}
