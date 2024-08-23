{config, ...}: {
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -al";
      vi = "nvim";
      vim = "nvim";

      # grep colors
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
    };

    history = {
      expireDuplicatesFirst = true;
      ignoreSpace = true;
      path = "${config.home.homeDirectory}/.local/share/zsh/zsh_history";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "command-not-found"
        "git"
        "sudo"
      ];
    };

    # appended to .zshrc
    initExtra = ''
      if test -n "$KITTY_INSTALLATION_DIR"; then
        export KITTY_SHELL_INTEGRATION="enabled"
        autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
        kitty-integration
        unfunction kitty-integration
      fi
    '';
  };

  home.persistence = {
    "/persist/home/spencer".directories = [".local/share/zsh"];
  };
}
