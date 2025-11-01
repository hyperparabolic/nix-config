{
  flake.modules.homeManager.core = {...}: {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      options = [
        "--cmd cd" #replace "cd"
      ];
    };

    home.persistence."/persist".directories = [".local/share/zoxide"];
  };
}
