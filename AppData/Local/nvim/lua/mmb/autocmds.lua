---------------------------------------------------------------
-- Sections
-- => Editing mappings
---------------------------------------------------------------

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
local mmb_group = vim.api.nvim_create_augroup("MMB", {})
local yank_group = vim.api.nvim_create_augroup("HighlightYank", {})

-- Delete trailing white space on save, useful for some filetypes ;)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = mmb_group,
  pattern = "*",
  callback = function(_)
    local cursor = vim.fn.getpos(".")
    local query = vim.fn.getreg("/")
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.setpos(".", cursor)
    vim.fn.setreg("/", query)
  end,
})

-- Set up LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = mmb_group,
  callback = function(ev)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help (LSP)", buffer = ev.buf })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Jump to definition (LSP)", buffer = ev.buf })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover information (LSP)", buffer = ev.buf })
    vim.keymap.set({ "n", "v" }, "<leader>gc", vim.lsp.buf.code_action, { desc = "Code action (LSP)", buffer = ev.buf })
    vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, { desc = "Show diagnostic", buffer = ev.buf })
    vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, { desc = "Rename all references (LSP)", buffer = ev.buf })
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "List all references (LSP)", buffer = ev.buf })
    vim.keymap.set(
      "n",
      "<leader>gw",
      vim.lsp.buf.workspace_symbol,
      { desc = "List all symbols (LSP)", buffer = ev.buf }
    )
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic", buffer = ev.buf })
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic", buffer = ev.buf })
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})
