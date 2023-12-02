
require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,

  hijack_directories = {
    enable = true,
    auto_open = true,
  },

  hijack_cursor = false,
  sync_root_with_cwd = false,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  view = {
    width = 25,
    side = "left",
  },
  actions = {
    open_file = {
      resize_window = true,
    },
  },
})

require("legendary").keymaps({
  { "<leader>tt", ":NvimTreeToggle<cr>", opts = { silent = true }, description = "Nvim Tree: Toggle" },
  { "<leader>tr", ":NvimTreeRefresh<cr>", opts = { silent = true }, description = "Nvim Tree: Refresh" },
  { "<leader>tf", ":NvimTreeFindFile<cr>", opts = { silent = true }, description = "Nvim Tree: Find file" },
})
