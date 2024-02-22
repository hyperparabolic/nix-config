{pkgs, ...}: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./config/plugin/lsp-config.lua;
      }
      # configured in lsp-config.lua
      nvim-lsp-ts-utils

      # easy lsp action discovery
      nvim-lightbulb
      # highlight selected symbol
      vim-illuminate

      # completion
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lsp-signature-help
      lspkind-nvim
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./config/plugin/lsp-config.lua;
      }
    ];

    extraPackages = with pkgs; [
      # language server packages
      nodejs

      # bash
      nodePackages.bash-language-server
      # lua
      lua-language-server
      # nix
      nil
      nixpkgs-fmt
      statix
      # typescript
      nodePackages.typescript-language-server
      # general web (html, css, etc)
      nodePackages.vscode-langservers-extracted
    ];
  };
}
