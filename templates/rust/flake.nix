{
  description = "Rust template with fenix and crane";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    crane.url = "github:ipetkov/crane";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    crane,
    fenix,
    systems,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    pkgsFor = forEachSystem (system:
      import nixpkgs {
        inherit system;
        overlays = [
          fenix.overlays.default
        ];
      });
    craneLib = forEachSystem (
      system:
        (crane.mkLib pkgsFor.${system}).overrideToolchain (
          p:
            p.fenix.stable.toolchain
        )
    );
  in {
    devShells = forEachSystem (system: {
      default = craneLib.${system}.devShell {
        packages = [];
      };
    });

    packages = forEachSystem (system: {
      default = craneLib.${system}.buildPackage {
        src = craneLib.${system}.cleanCargoSource ./.;
        strictDeps = true;
      };
    });

    apps = forEachSystem (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/rust_template";
      };
    });
  };
}
