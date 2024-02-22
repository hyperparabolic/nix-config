{config, ...}: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        width = 500;
        origin = "top-right";
        alignment = "left";
        vertical_alignment = "center";
        font = config.fontProfiles.monospace.family;
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = "do_action";
        mouse_middle_click = "close_all";
        mouse_right_click = "close_current";
      };
    };
  };
}
