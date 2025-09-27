{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      mgr = {
        show_hidden = true;
        show_symlink = true;
      };
    };
  };

  stylix.targets.yazi.enable = true;
}
