local gopls_group = vim.api.nvim_create_augroup("gopls", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = golps_group,
    pattern = { "*.go" },
    callback = function(ev)
        vim.lsp.buf.code_action({
            async = false,
            apply = true,
            context = {
                only = { "source.organizeImports" },
            },
        })
        vim.wait(500)
        vim.lsp.buf.format({ async = false })
    end,
})

return {
    cmd_env = { GOFUMPT_SPLIT_LONG_LINES = "on" },
    settings = {
        gopls = {
            gofumpt = true
        }
    }
}
