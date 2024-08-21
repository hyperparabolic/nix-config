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
      ./cli
      ./dev
      ./helix
      ./nvim
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
    };
  };

  home = {
    username = "spencer";
    homeDirectory = "/home/spencer";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      FLAKE = "$HOME/Documents/NixConfig";
    };

    persistence = {
      "/persist/home/spencer" = {
        directories = [
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
          ".local/bin"
          ".local/share/nix"
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
