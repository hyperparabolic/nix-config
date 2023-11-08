# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "spencer";
    homeDirectory = "/home/spencer";

    persistence = {
      "/persist/home/spencer" = {
        directories = [
          ".ssh"
	];
	allowOther = true;
      };
    };
  };

  programs.home-manager.enable = true;
  programs.neovim.enable = true;

  programs.git = {
    enable = true;
    userName = "Spencer Balogh";
    userEmail = "spbalogh@gmail.com";
  };

  # home.packages = with pkgs; [ ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
