{
  flake.modules.homeManager.core = {...}: {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        copy_command = "wl-copy";
        default_layout = "disable-status-bar";
        scroll_buffer_size = 4294967295;
        show_release_notes = false;
        show_startup_tips = false;
        theme = "catppuccin-macchiato";
        ui.pane_frames.rounded_corners = true;

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
              {
                bind = {
                  _args = ["Ctrl Shift /"];
                  _children = [
                    {
                      OverrideLayout._children = [
                        {layout._args = ["default"];}
                        {retain_existing_terminal_panes._args = [true];}
                        {apply_only_to_active_tab._args = [true];}
                      ];
                    }
                  ];
                };
              }
              {
                bind = {
                  _args = ["Ctrl /"];
                  _children = [
                    {
                      OverrideLayout._children = [
                        {layout._args = ["disable-status-bar"];}
                        {retain_existing_terminal_panes._args = [true];}
                        {apply_only_to_active_tab._args = [true];}
                      ];
                    }
                  ];
                };
              }
            ];
          };
        };
      };
    };
  };
}
