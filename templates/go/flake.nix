{
  description = "TODO go nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    nixpkgs,
    systems,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    pkgsFor = forEachSystem (system: import nixpkgs {inherit system;});

    pname = "TODO";
  in {
    devShells = forEachSystem (system: let
      pkgs = pkgsFor.${system};
    in {
      default = pkgsFor.${system}.mkShell {
        packages = with pkgs; [
          go
          gopls
          go-tools
          gotools
        ];
      };
    });

    packages = forEachSystem (system: {
      default = pkgsFor.${system}.buildGoModule {
        inherit pname;
        version = "0.0.1";
        src = ./.;
        vendorHash = null;
      };
    });
  };
}
