{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../common/optional/nginx.nix
    ./acme.nix
    ./hydra.nix
    ./immich.nix
    ./jellyfin.nix
    ./kavita.nix
    ./miniflux.nix
    ./nix-serve.nix
    ./postgres.nix
  ];

  # intentionally failing for metrics testing
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_5_10;
}
