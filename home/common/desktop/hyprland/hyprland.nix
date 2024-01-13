{ config, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$MOD" = "SUPER";
      # mostly wayland compat environment variables
      env = ''
        XDG_SESSION_TYPE,wayland
        XDG_SESSION_DESKTOP,Hyprland

        GDK_BACKEND,wayland

        MOZ_DISABLE_RDD_SANDBOX,1
        MOZ_ENABLE_WAYLAND,1

        OZONE_PLATFORM,wayland
      '';
      # startup programs
      exec-once = [

      ];
      general = {
        border_size = 1;
        # TODO: border colors
        gaps_in = 5;
        gaps_out = 5;
        layout = "dwindle";
        no_cursor_warps = true;
      };
      monitor =
      if builtins.length config.monitors > 0
        # if monitors are configured, map to exact config
        then map (m: let
          resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = "${toString m.x}x${toString m.y}";
          transform = "transform,${toString m.transform}";
        in
          "${m.name},${if m.enabled then "${resolution},${position},1" else "disable"},${if m.enabled then "${transform}" else ""}"
        ) (config.monitors)
        # if monitors are not configured, do your best prioritizing resolution
        else [ ",highres,auto,1" ];

      # TODO: decoration, animation
      input = {
        # rebind caps lock to hyper
        kb_options = "caps:hyper";
        # mouse settings
        accel_profile = "flat";
        sensitivity = 0.0;
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };
      misc = {
        animate_mouse_windowdragging = true;
        # `hyprctl reload` to reload
        disable_autoreload = true;
        vrr = 1;
      };
      # TODO: multiple monitor keybinds on desktop
      bind = [
        "$MOD, Escape, exec, wlogout -p layer-shell"

        "$MOD, R, exec, anyrun"

        "$MOD, Q, killactive"
        "$MODSHIFT, Q, exit"
        "$MOD, F, fullscreen"
        "$MOD, Space, togglefloating"
        "$MOD, P, pseudo"
        "$MOD, G, togglesplit"
        "$MODSHIFT, Space, workspaceopt, allfloat"
        "$MODSHIFT, P, workspaceopt, allpseudotile"

        "$MOD, Tab, swapnext"
        "$MODSHIFT, Tab, swapnext, prev"

        "$MOD, K, movefocus, u"
        "$MOD, J, movefocus, d"
        "$MOD, L, movefocus, r"
        "$MOD, H, movefocus, l"

        "$MODCTRL, K, swapwindow, u"
        "$MODCTRL, J, swapwindow, d"
        "$MODCTRL, L, swapwindow, r"
        "$MODCTRL, H, swapwindow, l"

        "$MODSHIFT, K, movewindow, u"
        "$MODSHIFT, J, movewindow, d"
        "$MODSHIFT, L, movewindow, r"
        "$MODSHIFT, H, movewindow, l"

        "$MOD, mouse_down, workspace, e-1"
        "$MOD, mouse_up, workspace, e+1"
        "${builtins.concatStringsSep "\n" (builtins.genList (x: let
            ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
          in ''
            bind = $MOD, ${ws}, workspace, ${toString (x + 1)}
            bind = $MODSHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          '')
          10)}"
      ];
      bindm = ["$MOD, mouse:272, movewindow" "$MOD, mouse:273, resizewindow"];
      # TODO: layers
      xwayland.force_zero_scaling = true;
    };


  };
}
