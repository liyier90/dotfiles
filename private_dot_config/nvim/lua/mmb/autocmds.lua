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
    callback = function(ev)
        cursor = vim.fn.getpos(".")
        query = vim.fn.getreg("/")
        vim.cmd([[silent! %s/\s\+$//e]])
        vim.fn.setpos(".", cursor)
        vim.fn.setreg("/", query)
    end,
})

-- Set up LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = mmb_group,
    callback = function(ev)
        local opts = {buffer = ev.buf}
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>gc", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>gw", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
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
