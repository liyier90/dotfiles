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

-- Navigate search results while ensuring the result is centered on the screen
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

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

-- Join line without losing cursor position
map("n", "J", "mzJ`z")

-- Navigate tabs
if vim.g.vscode == 1 then
    map("n", "H", "<Cmd>Tabprevious<cr>", default_opts)
    map("n", "L", "<Cmd>Tabnext<cr>", default_opts)
else
    map("n", "<leader>h", ":tabprevious<cr>", default_opts)
    map("n", "<leader>l", ":tabnext<cr>", default_opts)

    -- Navigate buffers
    map("n", "H", ":bprevious<cr>", default_opts)
    map("n", "L", ":bnext<cr>", default_opts)
end

-- Overwrite visual selection and paste
map("x", "<leader>p", [["_dP]])

-- Change d to be delete without copying to buffer
map({ "n", "v" }, "d", [["_d]], default_opts)
map({ "n", "v" }, "D", [["_D]], default_opts)

