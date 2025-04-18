local servers = {
    "basedpyright",
    "gopls",
    "jinja_lsp",
    "lua_ls",
    "ruff",
    "rust_analyzer",
}

local servers_set = {}
for _, server_name in ipairs(servers) do
    servers_set[server_name] = true
end

local function has_words_before()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

return {
    "neovim/nvim-lspconfig",
    tags = "v1.7.0",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/nvim-cmp",
        "j-hui/fidget.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_nvim_lsp.default_capabilities()
        )

        require("fidget").setup()
        require("mason").setup({
            max_concurrent_installers = 1,
        })
        require("mason-lspconfig").setup({
            ensure_installed = servers,
            automatic_installation = true,
            handlers = {
                function(server_name)
                    if servers_set[server_name] == nil then
                        return
                    end
                    local opts = { capabilities = capabilities }
                    local ok, server_opts = pcall(
                        require,
                        string.format("mmb.lazy.lsp.settings.%s", server_name))
                    if ok then
                        opts = vim.tbl_deep_extend("force", server_opts, opts)
                    end
                    require("lspconfig")[server_name].setup(opts)
                end,
            },
        })

        local cmp = require("cmp")
        local select_behavior = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and has_words_before() then
                        cmp.select_next_item(select_behavior)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item(select_behavior)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-j>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and has_words_before() then
                        cmp.select_next_item(select_behavior)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-k>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item(select_behavior)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["\\"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm({
                    select = false,
                }),
            }),
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    vim.snippet.expand(args.body)
                end
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
            }, {
                { name = "buffer" },
            }),
        })

        vim.diagnostic.config({
            float = {
                focusable = false,
                border = "rounded",
                header = "",
                prefix = "",
                source = "always",
                style = "minimal",
            },
            severity_sort = true,
            underline = true,
            virtual_text = false,
        })
    end,
}
