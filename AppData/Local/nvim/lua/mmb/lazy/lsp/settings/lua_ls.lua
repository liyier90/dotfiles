local lua_ls_group = vim.api.nvim_create_augroup("LuaLs", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = lua_ls_group,
    pattern = { "*.lua" },
    callback = function(ev)
        vim.lsp.buf.format({
            async = false,
            timeout_ms = 200,
        })
    end,
})

return {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            runtime = { version = "Lua 5.1" },
        },
    }
}
