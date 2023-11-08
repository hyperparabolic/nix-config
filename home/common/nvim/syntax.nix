{ pkgs, ... }: {
  # syntax highlighting specific configs and plugs
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      plantuml-syntax
      vim-jsx-typescript
      vim-markdown
      vim-nix
    ];
  };
}
