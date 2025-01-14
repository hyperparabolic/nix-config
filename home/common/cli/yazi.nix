{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        show_symlink = true;
      };
    };
  };
}
