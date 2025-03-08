local clang_format_group = vim.api.nvim_create_augroup("ClangFormat", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = clang_format_group,
    pattern = { "*.frag" },
    callback = function(ev)
        cursor = vim.fn.getpos(".")
        query = vim.fn.getreg("/")
        vim.cmd([[ %!clang-format ]])
        vim.fn.setpos(".", cursor)
        vim.fn.setreg("/", query)
    end,
})

return {}
