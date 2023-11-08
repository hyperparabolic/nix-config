{ pkgs, ... }: {
  imports = [
    ./ssh.nix
  ];
  # zero config packages
  home.packages = with pkgs; [
    glances # system monitor
    jq # json parsing
    ranger
    silver-searcher # ag

    nil # nix lsp
    nixfmt # nix formatter
  ];
}
