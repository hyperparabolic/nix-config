
local opt = vim.opt
local g = vim.g

-- global options --
opt.mouse = 'a'
opt.incsearch = true -- Find the next match as we type the search
opt.hlsearch = true -- Hilight searches by default
opt.viminfo = "'100,f1" -- Save up to 100 marks, enable capital marks
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true -- ...unless we type a capital
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 2
opt.shiftwidth = 0 -- use tabstop value
opt.softtabstop = 0 -- use tabstop value
opt.expandtab = true -- to spaces
opt.termguicolors = true
opt.cursorline = true
opt.relativenumber = true
opt.number = true

-- Set leader key
g.mapleader = " "

-- Color Scheme Settings
vim.cmd("syntax enable")

-- Movement keybinds
local opts = { noremap = true }
require("legendary").keymaps({
	{ "<C-h>", "<C-w>h", description = "Panes: Move left", opts = opts },
	{ "<C-j>", "<C-w>j", description = "Panes: Move down", opts = opts },
	{ "<C-k>", "<C-w>k", description = "Panes: Move up", opts = opts },
	{ "<C-l>", "<C-w>l", description = "Panes: Move right", opts = opts },
})
