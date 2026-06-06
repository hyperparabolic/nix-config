hl.on("hyprland.start", function()
  -- persistent workspaces linger, but only after they've been visited once.
  -- iterate persisted workspaces on startup
  hl.exec_cmd("hyprctl dispatch workspace 1")
  hl.exec_cmd("hyprctl dispatch workspace 2")
  hl.exec_cmd("hyprctl dispatch workspace 3")
  hl.exec_cmd("hyprctl dispatch workspace 4")
  hl.exec_cmd("hyprctl dispatch workspace 5")
  hl.exec_cmd("hyprctl dispatch workspace 6")
  hl.exec_cmd("hyprctl dispatch workspace 7")
  hl.exec_cmd("hyprctl dispatch workspace 8")
  hl.exec_cmd("hyprctl dispatch workspace 1")
  hl.exec_cmd("uwsm app -s s -- wl-paste --type text --watch cliphist store")
  hl.exec_cmd("uwsm app -s s -- wl-paste --type image --watch cliphist store")
  -- TODO: move to systemd services so they can be forced to start after vanity
  hl.exec_cmd("uwsm app -- easyeffects -l input_filter_voice")
  hl.exec_cmd("uwsm app -- slack")
  hl.exec_cmd("uwsm app -- discord")
end)
