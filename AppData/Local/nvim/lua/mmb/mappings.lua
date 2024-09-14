---------------------------------------------------------------
-- Sections
-- => General
-- => Moving around, tabs, windows, and buffers
-- => Editing mappings
---------------------------------------------------------------

---------------------------------------------------------------
-- => General
---------------------------------------------------------------
-- Set map leader to enable <leader> mappings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Fast saving
vim.keymap.set("n", "<leader>w", ":w!<CR>")
vim.keymap.set("n", "<leader>W", ":noautocmd w!<CR>")

---------------------------------------------------------------
-- => Moving around, tabs, windows, and buffers
---------------------------------------------------------------
-- Change vertical and horizontal split
vim.keymap.set("n", "<leader>\\", ":vsplit<CR>")
vim.keymap.set("n", "<leader>-", ":split<CR>")
vim.keymap.set("n", "<leader><leader>", "<C-w><C-w>")

-- Navigate search results while ensuring the result is centered on the screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Remap 0 to first non-blank character
vim.keymap.set({"n", "o", "v"}, "0", "^")

-- Move a line of text using [JK] in visual mode
vim.keymap.set("v", "J", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":move '<-2<CR>gv=gv")

-- Join line without losing cursor position
vim.keymap.set("n", "J", "mzJ`z")

-- Navigate tabs
if vim.g.vscode == 1 then
    vim.keymap.set("n", "H", "<Cmd>Tabprevious<CR>")
    vim.keymap.set("n", "L", "<Cmd>Tabnext<CR>")
else
    vim.keymap.set("n", "<leader>h", ":tabprevious<CR>")
    vim.keymap.set("n", "<leader>l", ":tabnext<CR>")

    -- Navigate buffers
    vim.keymap.set("n", "H", ":bprevious<CR>")
    vim.keymap.set("n", "L", ":bnext<CR>")
end

-- Overwrite visual selection and paste
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Change d to delete without copying to buffer
vim.keymap.set({"n", "v"}, "d", [["_d]])
vim.keymap.set({"n", "v"}, "D", [["_D]])

-- Search and replace the word under the cursor across the entire file
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Search for the word under the cursor
vim.keymap.set("n", "<leader>/", [[/\<<C-r><C-w><CR>]])

-- Toggle comment (recreate NERDCommenterToggle behavior)
vim.keymap.set("n", "<leader>c", "gc", {remap = true})
vim.keymap.set("v", "<leader>c<leader>", "gc", {remap = true})
