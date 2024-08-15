---------------------------------------------------------------
-- Sections
-- => General
-- => Moving around, tabs, windows, and buffers
-- => Editing mappings
---------------------------------------------------------------
local map = vim.keymap.set

---------------------------------------------------------------
-- => General
---------------------------------------------------------------
-- Fast saving
map("n", "<leader>w", ":w!<cr>")
map("n", "<leader>W", ":noautocmd w!<cr>")

---------------------------------------------------------------
-- => Moving around, tabs, windows, and buffers
---------------------------------------------------------------
-- Change vertical and horizontal split
map("n", "<C-w>\\", ":vsplit<cr>", { noremap = true })
map("n", "<C-w>-", ":split<cr>", { noremap = true })
map("n", "<leader><leader>", "<C-w><C-w>", { noremap = true})

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Remap VIM 0 to first non-blank character
map({ "n", "v", "o" }, "0", "^")

-- Move a line of text using CTRL+[jk]
map("n", "<C-j>", ":move .+1<cr>==", { noremap = true })
map("n", "<C-k>", ":move .-2<cr>==", { noremap = true })
map("i", "<C-j>", "<Esc>:move .+1<cr>==gi", { noremap = true })
map("i", "<C-k>", "<Esc>:move .-2<cr>==gi", { noremap = true })
map("v", "<C-j>", ":move '>+1<cr>gv=gv", { noremap = true })
map("v", "<C-k>", ":move '<-2<cr>gv=gv", { noremap = true })

-- Navigate tabs
map("n", "H", ":tabprevious<cr>", { noremap = true })
map("n", "L", ":tabnext<cr>", { noremap = true })

-- Change d to be delete without copying to buffer
map({ "n", "v" }, "d", '"_d', { noremap = true })
map({ "n", "v" }, "D", '"_D', { noremap = true })
