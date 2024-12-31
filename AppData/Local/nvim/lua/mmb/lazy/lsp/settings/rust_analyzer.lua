local rust_analyzer_group = vim.api.nvim_create_augroup("RustAnalyzer", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = rust_analyzer_group,
    pattern = { "*.rs" },
    callback = function(ev)
        vim.lsp.buf.format({
            async = false,
            timeout_ms = 200,
        })
    end,
})

return {}
