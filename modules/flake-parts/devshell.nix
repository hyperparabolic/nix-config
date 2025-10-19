{
  perSystem = {pkgs, ...}: {
    # bootstrapping and repo tooling
    devShells = {
      default = pkgs.mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes";
        buildInputs = with pkgs; [
          nix
          nix-diff
          git
          sops
          ssh-to-age
          gnupg
          age
          yq-go
          sbctl
        ];
      };
    };
  };
}
