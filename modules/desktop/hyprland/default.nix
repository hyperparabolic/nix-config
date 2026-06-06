{
  flake.modules.homeManager.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.sessionVariables = {
      # up to date stubs for luarc
      HYPRLAND_LUA_STUBS = "${config.wayland.windowManager.hyprland.package}/share/hypr/stubs/";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      # uwsm generated systemd units
      systemd.enable = false;
      configType = "lua";
      extraLuaFiles = {
        animations = ./animations.lua;
        binds = ./binds.lua;
        config = ./config.lua;
        rules = ./rules.lua;
        startup = ./startup.lua;
      };
      extraConfig =
        /*
        lua
        */
        ''
          hl.bind("SUPER + T", hl.dsp.exec_cmd("uwsm app -- foot"))

          -- allow screencopy for expected applications automatically
          hl.permission({ binary = "${lib.getExe pkgs.grim}", type = "screencopy", mode = "allow" })
          hl.permission({ binary = "${lib.getExe pkgs.hyprlock}", type = "screencopy", mode = "allow" })
          hl.permission({ binary = "${lib.getExe pkgs.hyprpicker}", type = "screencopy", mode = "allow" })
          hl.permission({ binary = "${pkgs.xdg-desktop-portal-hyprland}/libexec/.xdg-desktop-portal-hyprland-wrapped", type = "screencopy", mode = "allow" })

          -- monitors config
          ${
            lib.strings.join "\n" (
              if builtins.length config.this.monitors > 0
              # if monitors are configured, map to exact config
              then
                map (
                  m: let
                    resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
                    position = "${toString m.x}x${toString m.y}";
                  in
                    /*
                    lua
                    */
                    ''
                      hl.monitor({
                        output = "${m.name}",
                        mode = "${resolution}",
                        position = "${position}",
                        scale = 1,
                        transform = ${toString m.transform},
                      })
                    ''
                ) (config.this.monitors)
              # if monitors are not configured, do your best prioritizing resolution
              else [
                /*
                lua
                */
                ''
                  hl.monitor({
                    output = "",
                    mode = "preferred",
                    position = "auto",
                    scale = 1,
                  })
                ''
              ]
            )
          }

          -- workspaces config
          ${
            lib.strings.join "\n" (
              if builtins.length config.this.monitors > 0
              then
                lib.flatten (map (
                  m:
                    map (
                      mw:
                      /*
                      lua
                      */
                      ''
                        hl.workspace_rule({
                          workspace = "${mw}",
                          monitor = "${m.name}",
                          persistent = true,
                        })
                      ''
                    ) (m.workspaces)
                ) (config.this.monitors))
              else [
                /*
                lua
                */
                ''
                  hl.workspace_rule({ workspace = "1", persistent = true })
                  hl.workspace_rule({ workspace = "2", persistent = true })
                  hl.workspace_rule({ workspace = "3", persistent = true })
                  hl.workspace_rule({ workspace = "4", persistent = true })
                  hl.workspace_rule({ workspace = "5", persistent = true })
                  hl.workspace_rule({ workspace = "6", persistent = true })
                  hl.workspace_rule({ workspace = "7", persistent = true })
                  hl.workspace_rule({ workspace = "8", persistent = true })
                ''
              ]
            )
          }
        '';
    };
  };
}
