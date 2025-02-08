{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.stylix.nixosModules.stylix
      ./acme.nix
      ./bluetooth.nix
      ./fish.nix
      ./gamemode.nix
      ./networking.nix
      ./nix.nix
      ./notify.nix
      ./openssh.nix
      ./podman.nix
      ./prometheus-node-exporter.nix
      ./promtail.nix
      ./sops.nix
      ./stylix.nix
      ./tailscale.nix
      ./zsh.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  nixpkgs = {
    # only global overlays
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
  };

  time.timeZone = lib.mkDefault "America/Chicago";

  environment.wordlist.enable = true;

  environment.systemPackages = with pkgs; [
    helix
    pciutils # pci querying tooling
    usbutils # usb querying tooling
  ];

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
