{
  imports = [
    ../../common/optional/nginx.nix
    ./acme.nix
    ./hydra.nix
    ./immich.nix
    ./jellyfin.nix
    ./kavita.nix
    ./miniflux.nix
    ./nix-serve.nix
    ./ntfy.nix
    ./postgres.nix
  ];
}
