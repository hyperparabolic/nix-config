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

        keybinds = {
          "shared_except \"locked\"" = {
            _children = [
              {
                bind = {
                  _args = ["Alt Tab"];
                  _children = [
                    {GoToNextTab = {};}
                    {SwitchToMode._args = ["normal"];}
                  ];
                };
              }
            ];
          };
        };
      };
    };

    stylix.targets.zellij.enable = true;
  };
}
