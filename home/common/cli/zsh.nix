{ config, ... }: {
  programs.zsh = {
    enable = true;

    enableAutosuggestions = true;
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
      plugins = [
        "ag"
        "command-not-found"
        "git"
        "sudo"
      ];
    };
  };

  home.persistence = {
    "/persist/home/spencer".directories = [ ".local/share/zsh" ];
  };
}
