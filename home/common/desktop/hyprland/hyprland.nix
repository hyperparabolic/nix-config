{
  config,
  lib,
  ...
}: {
  # wayland compatibility environment variables
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$MOD" = "SUPER";

      # startup programs
      exec-once = [
        # TODO: persist this in the nix store?
        "swaybg -i ~/Pictures/wallpapers/wallpaper.jpg -m fill"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "slack"
        "discord"
      ];

      general = {
        border_size = 1;
        gaps_in = 10;
        gaps_out = 15;
        "col.active_border" = "0xffa9763b";
        layout = "dwindle";
        no_cursor_warps = true;
      };

      monitor =
        if builtins.length config.monitors > 0
        # if monitors are configured, map to exact config
        then
          map (
            m: let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
              transform = "transform,${toString m.transform}";
            in "${m.name},${
              if m.enabled
              then "${resolution},${position},1"
              else "disable"
            },${
              if m.enabled
              then "${transform}"
              else ""
            }"
          ) (config.monitors)
        # if monitors are not configured, do your best prioritizing resolution
        else [",highres,auto,1"];

      workspace =
        if builtins.length config.monitors > 0
        then
          lib.flatten (map (
            m:
              map (
                mw: "${mw}, monitor:${m.name}, persistent: true"
              ) (m.workspaces)
          ) (config.monitors))
        else [
          "1, persistent: true"
          "2, persistent: true"
          "3, persistent: true"
          "4, persistent: true"
          "5, persistent: true"
          "6, persistent: true"
          "7, persistent: true"
          "8, persistent: true"
        ];

      decoration = {
        active_opacity = 0.95;
        inactive_opacity = 0.8;
        fullscreen_opacity = 1.0;
        rounding = 10;
      };

      input = {
        # rebind caps lock to hyper
        kb_options = "caps:hyper";
        # mouse settings
        accel_profile = "flat";
        sensitivity = 0.0;
        follow_mouse = 2;
        touchpad = {
          natural_scroll = true;
        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      misc = {
        animate_mouse_windowdragging = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        # `hyprctl reload` to reload
        disable_autoreload = true;
        key_press_enables_dpms = true;
        vrr = 1;
      };

      bind = [
        "$MOD, Escape, exec, wlogout -p layer-shell"
        ", Print, exec, grimblast --notify copysave screen"
        "ALT, Print, exec, grimblast --notify copysave output"
        "$MODSHIFT, S, exec, grimblast --notify copysave area"

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

      windowrulev2 = [
        "opaque,class:^(krita)$"

        "idleinhibit always, class:^(kitty)$, title:^(./win10-vm-start.sh)$"
        "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(firefox)$"

        "workspace 4, class:^(Slack)$"
        "noinitialfocus, class:^(Slack)$"
        "workspace 4, class:^(discord)$"
        "noinitialfocus, class:^(discord)$"
      ];

      xwayland.force_zero_scaling = true;
    };
  };
}
