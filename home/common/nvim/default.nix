{ pkgs, ... }: {
  imports = [
    ./syntax.nix
  ];

  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;

    extraConfig = ''
      set mouse=a " mouse support
      set clipboard=unnamedplus " use system clipboard
      set hidden " hide buffers instead of closing

      " hybrid line numbers (absolute for current and relative otherwise)
      set number relativenumber
      
      " indentation settings
      set expandtab " spaces
      set autoindent
      set smartindent " language specific indents
      set tabstop=4 " 4 character wide tabs
      set softtabstop=0 " use tabstop value
      set shiftwidth=0 " use tabstop value
      " overrides to 2 spaces
      augroup two_space_tab
        autocmd!
        autocmd FileType json,html,nix,typescript,terraform setlocal tabstop=2
      augroup END
    '';

    plugins = with pkgs.vimPlugins; [
      editorconfig-nvim
      vim-surround
    ];
  };
}
