{
  flake.modules.homeManager.core = {...}: {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "y";

      settings = {
        mgr = {
          show_hidden = true;
          show_symlink = true;
        };
      };
    };

    stylix.targets.yazi.enable = true;
  };
}
