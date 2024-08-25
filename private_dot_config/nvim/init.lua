-- Set map leader to enable <leader> mappings.
-- like <leader>w saves the current file
vim.g.mapleader = " "

require("user.options")
require("user.mappings")
require("user.plugins")
require("user.telescope")
require("user.cmp")
require("user.lsp")
require("user.treesitter")
require("user.autocmds")
require("user.colors")
