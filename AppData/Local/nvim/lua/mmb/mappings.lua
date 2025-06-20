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

vim.keymap.set("n", "<leader>w", ":w!<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>W", ":noautocmd w!<CR>", { desc = "SAVE" })

---------------------------------------------------------------
-- => Moving around, tabs, windows, and buffers
---------------------------------------------------------------
vim.keymap.set("n", "<leader>\\", ":vsplit<CR>", { desc = "Split V" })
vim.keymap.set("n", "<leader>-", ":split<CR>", { desc = "Split H" })
vim.keymap.set("n", "<leader><leader>", "<C-w><C-w>", { desc = "Split cycle" })

-- Navigate search results while ensuring the result is centered on the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "Next" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev" })

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
vim.keymap.set("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move line up" })

-- Join line without losing cursor position
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line" })

-- Navigate tabs
if vim.g.vscode == 1 then
  vim.keymap.set("n", "H", "<Cmd>Tabprevious<CR>")
  vim.keymap.set("n", "L", "<Cmd>Tabnext<CR>")
else
  vim.keymap.set("n", "<leader>h", ":tabprevious<CR>", { desc = "Tab prev" })
  vim.keymap.set("n", "<leader>l", ":tabnext<CR>", { desc = "Tab next" })

  -- Navigate buffers
  vim.keymap.set("n", "H", ":bprevious<CR>", { desc = "Buffer prev" })
  vim.keymap.set("n", "L", ":bnext<CR>", { desc = "Buffer next" })
end

-- Overwrite visual selection and paste
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste" })

-- Change d to delete without copying to buffer
vim.keymap.set({ "n", "v" }, "d", [["_d]], { desc = "Delete" })
vim.keymap.set({ "n", "v" }, "D", [["_D]], { desc = "Delete" })

-- Search and replace the word under the cursor across the entire file
vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word in file" }
)

-- Toggle comment (recreate NERDCommenterToggle behavior)
vim.keymap.set("n", "<leader>c", "gc", { desc = "Comment toggle", remap = true })
vim.keymap.set("v", "<leader>c<leader>", "gc", { desc = "Comment toggle", remap = true })
