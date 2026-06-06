hl.curve("easeoutquad", {
  type = "bezier",
  points = { { 0.25, 0.46 }, { 0.45, 0.94 } }
})
hl.curve("easeinoutcirc", {
  type = "bezier",
  points = { { 0.785, 0.135 }, { 0.15, 0.86 } }
})

hl.animation({
  leaf = "border",
  enabled = true,
  speed = 5,
  bezier = "easeoutquad",
})
hl.animation({
  leaf = "fadeIn",
  enabled = true,
  speed = 3,
  bezier = "easeoutquad",
})
hl.animation({
  leaf = "fadeOut",
  enabled = true,
  speed = 3,
  bezier = "easeoutquad",
})
hl.animation({
  leaf = "fadeLayers",
  enabled = true,
  speed = 3,
  bezier = "easeoutquad",
})
hl.animation({
  leaf = "fadeSwitch",
  enabled = true,
  speed = 5,
  bezier = "easeoutquad",
})
hl.animation({
  leaf = "layers",
  enabled = true,
  speed = 3,
  bezier = "easeinoutcirc",
  style = "slide",
})
hl.animation({
  leaf = "windowsIn",
  enabled = true,
  speed = 5,
  bezier = "easeoutquad",
  style = "slide",
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 5,
  bezier = "easeoutquad",
  style = "slide",
})
hl.animation({
  leaf = "windowsMove",
  enabled = true,
  speed = 5,
  bezier = "easeinoutcirc",
  style = "slide",
})
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 3,
  bezier = "easeinoutcirc",
  style = "slidefade",
})
