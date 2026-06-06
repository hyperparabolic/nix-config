-- screenshot + utils
hl.bind("Print", hl.dsp.exec_cmd("grimblast --notify copysave screen"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("grimblast --notify copysave output"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grimblast --notify copysave area"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("grimblast --notify copy area"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

-- launchers
hl.bind("SUPER + R", hl.dsp.exec_cmd("walker"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("walker -m clipboard"))

hl.bind("SUPER + Escape", hl.dsp.exec_cmd("loginctl lock-session"), { locked = true })

-- window management
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Tab", hl.dsp.window.swap({ next = true }))
hl.bind("SUPER + SHIFT + Tab", hl.dsp.window.swap({ prev = true }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + CTRL + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + CTRL + J", hl.dsp.window.swap({ direction = "d" }))
hl.bind("SUPER + CTRL + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + CTRL + H", hl.dsp.window.swap({ direction = "l" }))

-- group management
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ into_or_create_group = "d" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ into_or_create_group = "r" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind("SUPER + G", hl.dsp.submap("group"))

hl.define_submap("group", function()
  hl.bind("SUPER + G", hl.dsp.group.toggle())
  hl.bind("SUPER + G", hl.dsp.submap("reset"))
  hl.bind("SUPER + Tab", hl.dsp.group.next())
  hl.bind("SUPER + SHIFT + Tab", hl.dsp.group.prev())
  hl.bind("SUPER + 1", hl.dsp.group.active({ index = 1 }))
  hl.bind("SUPER + 2", hl.dsp.group.active({ index = 2 }))
  hl.bind("SUPER + 3", hl.dsp.group.active({ index = 3 }))
  hl.bind("SUPER + 4", hl.dsp.group.active({ index = 4 }))
  hl.bind("SUPER + 5", hl.dsp.group.active({ index = 5 }))
  hl.bind("SUPER + 6", hl.dsp.group.active({ index = 6 }))
  hl.bind("SUPER + l", hl.dsp.group.lock({ action = "toggle" }))
  hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- workspace management
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "m-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "m+1" }))

for i = 0, 9, 1 do
  local ws = tostring(i)
  hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = ws }))
  hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- multimedia keys
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"), { locked = true, repeating = true })

-- mouse and touchpad movement
hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
