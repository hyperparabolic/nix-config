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
      inputs.nixos-hydra-upgrade.nixosModules.nixos-hydra-upgrade
      ./acme.nix
      ./bluetooth.nix
      ./fish.nix
      ./gamemode.nix
      ./networking.nix
      ./nix.nix
      ./nixos-hydra-upgrade.nix
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
    sharedModules =
      [
        inputs.impermanence.homeManagerModules.impermanence
        inputs.stylix.homeModules.stylix
        inputs.walker.homeManagerModules.default
      ]
      ++ (builtins.attrValues outputs.homeManagerModules);
  };

  time.timeZone = lib.mkDefault "America/Chicago";

  environment = {
    enableAllTerminfo = true;
    wordlist.enable = true;
    systemPackages = with pkgs; [
      hyperparabolic-bootstrap

      helix
    ];
  };

  services = {
    dbus.implementation = "broker";
    # firmware updates: `fwupdmgr update`
    fwupd.enable = true;
  };

  environment.persistence."/persist".directories = [
    "/var/lib/systemd"
    "/var/lib/nixos"
    "/var/log"
    "/srv"
  ];

  programs = {
    dconf.enable = true;
    fuse.userAllowOther = true;
  };

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
