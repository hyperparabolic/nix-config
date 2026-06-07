hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -s s -- wl-paste --type text --watch cliphist store")
  hl.exec_cmd("uwsm app -s s -- wl-paste --type image --watch cliphist store")
  -- TODO: move to systemd services so they can be forced to start after vanity
  hl.exec_cmd("uwsm app -- easyeffects -l input_filter_voice")
  hl.exec_cmd("uwsm app -- slack")
  hl.exec_cmd("uwsm app -- discord")
end)
