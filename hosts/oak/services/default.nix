{
  imports = [
    ../../common/optional/nginx.nix
    ./acme.nix
    ./hydra.nix
    ./jellyfin.nix
    ./miniflux.nix
    ./nix-serve.nix
    ./postgres.nix
  ];
}
