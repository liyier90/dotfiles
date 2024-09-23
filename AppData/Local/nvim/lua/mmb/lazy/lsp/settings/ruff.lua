local ruff_group = vim.api.nvim_create_augroup("Ruff", {})

vim.api.nvim_create_autocmd("LspAttach", {
    group = ruff_group,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
            return
        end
        if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
    desc = "LSP: Disable hover capability from Ruff",
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = ruff_group,
    pattern = { "*.py" },
    callback = function(ev)
        vim.lsp.buf.code_action({
            async = false,
            apply = true,
            context = {
                only = { "source.organizeImports.ruff" },
            },
        })
        vim.wait(500)
        vim.lsp.buf.format({
            async = false,
            filter = function(client)
                return client.name == "ruff"
            end,
        })
    end,
})

return {
    init_options = {
        settings = {
            lint = {
                enable = false,
            },
        },
    },
}
