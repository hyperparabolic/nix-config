{
  imports = [
    ../../common/optional/nginx.nix
    ./acme.nix
    ./jellyfin.nix
    ./nix-serve.nix
  ];
}
