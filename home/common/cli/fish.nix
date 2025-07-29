{
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
    };
    shellAbbrs = {
      cat = "bat -pp";
      less = "bat -p";
      ls = "eza";
      la = "eza -a";
      ll = "eza -alg";
      tree = "eza --tree";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
    };
  };

  home.persistence = {
    "/persist/home/spencer".directories = [".local/share/fish"];
  };
}
