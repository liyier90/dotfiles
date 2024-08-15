---------------------------------------------------------------
-- Sections
-- => Editing mappings
-- => LSP
---------------------------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Delete trailing white space on save, useful for some filetypes ;)
autocmd("BufWritePre", {
    pattern = { "*.txt", "*.js", "*.py", "*.sh" },
    callback = function(ev)
        cursor = vim.fn.getpos(".")
        old_query = vim.fn.getreg("/")
        vim.cmd([[silent! %s/\s\+$//e]])
        vim.fn.setpos(".", cursor)
        vim.fn.setreg("/", old_query)
    end,
})

---------------------------------------------------------------
-- => LSP
---------------------------------------------------------------
-- Auto open float window on hover
autocmd("CursorHold", {
    pattern = { "*" },
    callback = function(ev)
        for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).zindex then
                return
            end
        end
        vim.diagnostic.open_float({focusable = false})
    end,
})
