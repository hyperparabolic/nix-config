{
  flake.modules.nixos.core = {...}: {
    programs.fish = {
      enable = true;
      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
  };

  flake.modules.homeManager.core = {...}: {
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

    stylix.targets.fish.enable = true;

    home.persistence."/persist".directories = [".local/share/fish"];
  };
}
