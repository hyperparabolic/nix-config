{ inputs, outputs, config, lib, ... }: {
  imports = [
    ./nix.nix
    ./openssh.nix
    ./sops.nix
    ./zsh.nix
  ];

  nixpkgs = {
    # only global overlays
    overlays = [];
    config = {
      allowUnfree = true;
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
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
