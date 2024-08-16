vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.py" },
    callback = function(ev)
        vim.lsp.buf.code_action({
            async = false,
            apply = true,
            context = {
                only = { "source.organizeImports.ruff" },
            },
        })
        vim.wait(100)
        vim.lsp.buf.format({
            async = false,
            filter = function(client)
                return client.name == "ruff_lsp"
            end,
        })
    end,
})

return {
    settings = {
        python = {
            analysis = {
                ignore = { "*" },
            },
        },
    },
}
