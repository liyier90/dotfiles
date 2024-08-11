---------------------------------------------------------------
-- Sections
-- => Editing mappings
---------------------------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Delete trailing white space on save, useful for some filetypes ;)
autocmd({ "BufWritePre" }, {
    pattern = { "*.txt", "*.js", "*.py", "*.sh" },
    callback = function(ev)
        cursor = vim.fn.getpos(".")
        old_query = vim.fn.getreg("/")
        vim.cmd([[silent! %s/\s\+$//e]])
        vim.fn.setpos(".", cursor)
        vim.fn.setreg("/", old_query)
    end,
})

