{lib, pkgs, ...}: {
  imports = [
    # TODO: debugger adapter protocol integration
    ./copilot.nix
    ./lsp.nix
    ./syntax.nix
    ./ui.nix
  ];

  home.sessionVariables.EDITOR = lib.mkDefault "nvim";

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./config/options.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      vim-sensible
      editorconfig-nvim
      vim-surround
      {
        plugin = nvim-autopairs;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require('nvim-autopairs').setup({})
          '';
      }
    ];

    extraPackages = with pkgs; [
      # clipboards for any windowing system
      wl-clipboard
      xclip

      # tools for telescope
      ripgrep
      fd
    ];
  };
}
