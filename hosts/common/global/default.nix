{
  inputs,
  outputs,
  config,
  lib,
  ...
}: {
  imports =
    [
      ./acme.nix
      ./bluetooth.nix
      ./gamemode.nix
      ./nix.nix
      ./notify.nix
      ./openssh.nix
      ./podman.nix
      ./sops.nix
      ./tailscale.nix
      ./zsh.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  nixpkgs = {
    # only global overlays
    overlays = [];
    config = {
      allowUnfree = true;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
  };

  time.timeZone = lib.mkDefault "America/Chicago";

  # global persistence
  environment.persistence = {
    "/persist" = {
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/log"
        "/srv"
      ];
    };
  };
  programs.fuse.userAllowOther = true;

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
