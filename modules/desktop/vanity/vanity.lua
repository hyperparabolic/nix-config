-- rules and binds specifically for vanity shell

-- binds
hl.bind("SUPER + E", hl.dsp.exec_cmd("vanity --toggle-menu"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("vanity --toggle-idle"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("vanity --toggle-notifications"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("vanity --notify-activate"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("vanity --notify-dismiss"))

-- layer rules
hl.layer_rule({
  match = { namespace = "^(bar-.*)$" },
  order = 99,
})
hl.layer_rule({
  match = { namespace = "menu" },
  no_screen_share = true,
})
hl.layer_rule({
  match = { namespace = "notifications" },
  no_screen_share = true,
})
hl.layer_rule({
  match = { namespace = "^(osd-.*)$" },
  animation = "popin",
  above_lock = 1,
  no_screen_share = true,
})
