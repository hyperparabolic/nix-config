{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./cli
    ./dev
    ./helix
    ./stylix.nix
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      warn-dirty = false;
    };
  };

  home = {
    username = "spencer";
    homeDirectory = "/home/spencer";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];

    persistence."/persist".directories = [
      "Documents"
      "Downloads"
      "Pictures"
      "Videos"
      ".local/bin"
      ".local/share/nix"
      ".nix-config"
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  dconf.settings = {
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true;
    };
    "org/virt-manager/virt-manager/connections" = {
      uris = ["qemu:///system"];
      autoconnect = ["qemu:///system"];
    };
  };
}
