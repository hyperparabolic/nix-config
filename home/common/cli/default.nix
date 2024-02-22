{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./ranger.nix
    ./ssh.nix
    ./zsh.nix
  ];
  # zero config packages
  home.packages = with pkgs; [
    glances # system monitor
    jq # json parsing
    silver-searcher # ag

    nil # nix lsp
    nixfmt # nix formatter
  ];
}
