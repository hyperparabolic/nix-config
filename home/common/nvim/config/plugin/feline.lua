
-- Disable status bar on these buffers
local disable = {
	filetypes = {
		"^NvimTree$",
		"^packer$",
		"^startify$",
		"^fugitive$",
		"^fugitiveblame$",
		"^qf$",
		"^help$",
		"^minimap$",
		"^Trouble$",
		"^dap-repl$",
		"^dapui_watches$",
		"^dapui_stacks$",
		"^dapui_breakpoints$",
		"^dapui_scopes$",
	},
	buftypes = {
		"^terminal$",
	},
	bufnames = {},
}

require("feline").setup({
	disable = disable,
})
