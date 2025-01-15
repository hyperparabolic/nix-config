{
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
    };
    shellAbbrs = {
      ll = "ls -al";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
    };
  };

  home.persistence = {
    "/persist/home/spencer".directories = [".local/share/fish"];
  };
}
