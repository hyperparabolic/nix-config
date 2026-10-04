hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -s s -- wl-paste --type text --watch cliphist store")
  hl.exec_cmd("uwsm app -s s -- wl-paste --type image --watch cliphist store")
end)
