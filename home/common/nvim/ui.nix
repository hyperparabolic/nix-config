{ pkgs, ... }: {
  # syntax highlighting specific configs and plugs
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      # keybinds helper
      {
        plugin = legendary-nvim;
        type = "lua";
        config = builtins.readFile ./config/plugin/legendary.lua;
      }

      # file tree
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ./config/plugin/nvim-tree.lua;
      }
      nvim-web-devicons

      # status line
      {
        plugin = feline-nvim;
        type = "lua";
        # TODO: theming
        # https://github.com/famiu/feline.nvim#screenshots
        config = builtins.readFile ./config/plugin/feline.lua;
      }

      # git ui elements
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = /* lua */ ''
          require("gitsigns").setup()
        '';
      }

      # show indent level
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = /* lua */ ''
          require("ibl").setup()
        '';
      }

      # fuzzy finder window
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./config/plugin/telescope.lua;
      }

      # errors view window
      {
        plugin = trouble-nvim;
        type = "lua";
        config = builtins.readFile ./config/plugin/trouble.lua;
      }

      # improved selection windows
      {
        plugin = dressing-nvim;
        type = "lua";
        config = /* lua */ ''
          require("dressing").setup({})
        '';
      }

      # tabs
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = builtins.readFile ./config/plugin/bufferline.lua;
      }

      # less jarring scrolling
      vim-smoothie

      # peek goto line
      {
        plugin = numb-nvim;
        type = "lua";
        config = /* lua */ ''
          require("numb").setup()
        '';
      }

      # navigation
      {
        plugin = leap-nvim;
        type = "lua";
        config = /* lua */ ''
          require("leap").add_default_mappings()
        '';
      }

      # rainbow delimiters
      rainbow-delimiters-nvim

      # notifications
      {
        plugin = fidget-nvim;
        type = "lua";
        config = /* lua */ ''
          require("fidget").setup({
            text = {
              spinner = "dots",
            },
          })
        '';
      }

      # comment toggling
      {
        plugin = comment-nvim;
        type = "lua";
        config = /* lua */ ''
          require("Comment").setup()
        '';
      }
    ];
  };
}