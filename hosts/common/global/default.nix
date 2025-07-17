{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: let
  hyperparabolic-bootstrap = pkgs.writeShellApplication {
    name = "hyperparabolic-bootstrap";
    runtimeInputs = with pkgs; [
      rsync

      age
      ssh-to-age
      sops
      yq-go
    ];
    text = builtins.readFile ../../../scripts/hyperparabolic-bootstrap.sh;
  };
in {
  imports =
    [
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
      ./tailscale.nix
      ./yubikey.nix
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
    hyperparabolic-bootstrap

    helix
    pciutils # pci querying tooling
    usbutils # usb querying tooling
  ];

  # firmware updates: `fwupdmgr update`
  services.fwupd.enable = true;

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
