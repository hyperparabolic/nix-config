{ inputs, config, lib, ... }: {
  imports = [
    ./nix.nix
    ./sops.nix
  ];

  nixpkgs = {
    # only global overlays
    overlays = [];
    config = {
      allowUnfree = true;
    };
  };

  time.timeZone = lib.mkDefault "America/Chicago";
}
