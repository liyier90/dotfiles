---------------------------------------------------------------
-- Sections
-- => General
-- => Moving around, tabs, windows, and buffers
-- => Editing mappings
---------------------------------------------------------------
local map = vim.keymap.set
-- No remap by default
local default_opts = { noremap = true }

---------------------------------------------------------------
-- => General
---------------------------------------------------------------
-- Fast saving
map("n", "<leader>w", ":w!<cr>", default_opts)
map("n", "<leader>W", ":noautocmd w!<cr>", default_opts)

---------------------------------------------------------------
-- => Moving around, tabs, windows, and buffers
---------------------------------------------------------------
-- Change vertical and horizontal split
map("n", "<leader>\\", ":vsplit<cr>", default_opts)
map("n", "<leader>-", ":split<cr>", default_opts)
map("n", "<leader><leader>", "<C-w><C-w>", default_opts)

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Remap VIM 0 to first non-blank character
map({ "n", "v", "o" }, "0", "^", default_opts)

-- Move a line of text using CTRL+[jk]
map("n", "<C-j>", ":move .+1<cr>==", default_opts)
map("n", "<C-k>", ":move .-2<cr>==", default_opts)
map("i", "<C-j>", "<Esc>:move .+1<cr>==gi", default_opts)
map("i", "<C-k>", "<Esc>:move .-2<cr>==gi", default_opts)
map("v", "<C-j>", ":move '>+1<cr>gv=gv", default_opts)
map("v", "<C-k>", ":move '<-2<cr>gv=gv", default_opts)

-- Navigate tabs
if vim.g.vscode == 1 then
    map("n", "H", "<Cmd>Tabprevious<cr>", default_opts)
    map("n", "L", "<Cmd>Tabnext<cr>", default_opts)
else
    map("n", "H", ":tabprevious<cr>", default_opts)
    map("n", "L", ":tabnext<cr>", default_opts)
end

-- Navigate buffers
map("n", "U", ":bprevious<cr>", default_opts)
map("n", "P", ":bnext<cr>", default_opts)

map({ "n", "v" }, "<leader>p", "P", default_opts)

-- Change d to be delete without copying to buffer
map({ "n", "v" }, "d", '"_d', default_opts)
map({ "n", "v" }, "D", '"_D', default_opts)
