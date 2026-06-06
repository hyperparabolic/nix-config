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
      extraConfig = let
        hasMonitorsConfig = builtins.length config.this.monitors > 0;

        # if no this.monitors, default to these configs
        defaultMonitors =
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
          '';
        defaultWorkspaces =
          /*
          lua
          */
          ''
            for i = 1, 8, 1 do
              local ws = tostring(i)
              hl.workspace_rule({ workspace = ws, persistent = true })
            end
          '';

        makeMonitor = mon: let
          mode = "${toString mon.width}x${toString mon.height}@${toString mon.refreshRate}";
          position = "${toString mon.x}x${toString mon.y}";
        in
          /*
          lua
          */
          ''
            hl.monitor({
              output = "${mon.name}",
              mode = "${mode}",
              position = "${position}",
              scale = 1,
              transform = ${toString mon.transform},
            })
          '';

        monitors =
          if !hasMonitorsConfig
          then defaultMonitors
          else
            config.this.monitors
            |> map makeMonitor
            |> lib.strings.join "";

        # make all workspace configs for a monitor
        makeWorkspaces = mon:
          map (ws:
            /*
            lua
            */
            ''
              hl.workspace_rule({
                workspace = "${ws}",
                monitor = "${mon.name}",
                persistent = true,
              })
            '') (mon.workspaces);

        workspaces =
          if !hasMonitorsConfig
          then defaultWorkspaces
          else
            config.this.monitors
            |> map makeWorkspaces
            # array of array of strings
            |> lib.flatten
            # array of strings
            |> lib.strings.join "";
      in
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
          ${monitors}

          -- workspaces config
          ${workspaces}
        '';
    };
  };
}
