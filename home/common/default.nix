{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.stylix.homeModules.stylix
      ./cli
      ./dev
      ./helix
      ./stylix.nix
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

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
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };

  home = {
    username = "spencer";
    homeDirectory = "/home/spencer";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];

    persistence = {
      "/persist/home/spencer" = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
          ".local/bin"
          ".local/share/nix"
          ".nix-config"
        ];
        allowOther = true;
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  # persist virt-manager connections
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      uris = ["qemu:///system"];
      autoconnect = ["qemu:///system"];
    };
  };
}
