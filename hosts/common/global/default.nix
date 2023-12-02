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

  # increase file handle limits for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];
}
