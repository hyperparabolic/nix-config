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
}
