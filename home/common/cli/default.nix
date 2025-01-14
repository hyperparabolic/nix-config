{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./ssh.nix
    ./starship.nix
    ./yazi.nix
    ./zsh.nix
  ];
  # zero config packages
  home.packages = with pkgs; [
    glances # system monitor
    jq # json parsing
    silver-searcher # ag

    alejandra # nix formatter
    nixd # nix lsp
  ];
}
