{ pkgs, ... }: {
  # syntax highlighting specific configs and plugs
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      plantuml-syntax

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = /* lua */ ''
          require("nvim-treesitter.configs").setup({
            highlight = {
              enable = true,
            },
            rainbow = {
              enable = true,
              extended_mode = true,
              max_file_lines = nil,
            },
          })
        '';
      }

      vim-jsx-typescript
      vim-markdown
      vim-nix
    ];
  };
}
