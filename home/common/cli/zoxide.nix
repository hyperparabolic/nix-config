{
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd" #replace "cd"
    ];
  };

  home.persistence."/persist/home/spencer".directories = [".local/share/zoxide"];
}
