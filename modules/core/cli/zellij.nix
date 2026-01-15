{
  flake.modules.homeManager.core = {...}: {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        copy_command = "wl-copy";
        scroll_buffer_size = 4294967295;
        show_release_notes = true;
        show_startup_tips = true;
      };
    };

    stylix.targets.zellij.enable = true;
  };
}
