hl.layer_rule({
  match = { namespace = "match:namespace hyprpaper" },
  animation = "fade",
})
hl.layer_rule({
  match = { namespace = "match:namespace hyprpicker" },
  animation = "fade",
})
hl.layer_rule({
  match = { namespace = "match:namespace selection" },
  animation = "fade",
})
hl.layer_rule({
  match = { namespace = "match:namespace walker" },
  no_screen_share = true,
})

hl.window_rule({
  match = {
    class = "^(krita)$",
  },
  opaque = true,
})
hl.window_rule({
  match = {
    class = "^(firefox)$",
  },
  idle_inhibit = "fullscreen",
})
hl.window_rule({
  match = {
    class = "^(slack)$",
  },
  workspace = "4",
  no_initial_focus = true,
})
hl.window_rule({
  match = {
    class = "^(discord)$",
  },
  workspace = "4",
  no_initial_focus = true,
})
hl.window_rule({
  match = {
    class = "^(vesktop)$",
  },
  workspace = "4",
  no_initial_focus = true,
})
-- handle zoom popups
hl.window_rule({
  match = {
    class = "^(zoom)$",
    title = "^(menu window)$",
  },
  stay_focused = true,
})
-- auth popups
hl.window_rule({
  match = {
    class = "gcr-prompter",
  },
  animation = "popin",
  no_screen_share = true,
  stay_focused = true,
  dim_around = true,
})
hl.window_rule({
  match = {
    class = "polkit-gnome-authentication-agent-1",
  },
  animation = "popin",
  no_screen_share = true,
  stay_focused = true,
  dim_around = true,
})
