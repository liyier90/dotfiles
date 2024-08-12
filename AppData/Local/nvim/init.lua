-- Set map leader to enable <leader> mappings.
-- like <leader>w saves the current file
vim.g.mapleader = ","

require("plugin_config")
require("lsp_config")
require("options")
require("mappings")
require("autocmds")
