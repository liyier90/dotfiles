---------------------------------------------------------------
-- => hrsh7th/nvim-cmp
-- => hrsh7th/cmp-nvim-lsp
-- => neovim/nvim-lspconfig
-- => williamboman/mason.nvim
-- => williamboman/mason-lspconfig.nvim
---------------------------------------------------------------
local lsp = vim.lsp
local map = vim.keymap.set
local servers = { "basedpyright", "ruff_lsp" }

---------------------------------------------------------------
-- => williamboman/mason.nvim
---------------------------------------------------------------
require("mason").setup({
    max_concurrent_installers = 1,
})

---------------------------------------------------------------
-- => williamboman/mason-lspconfig.nvim
---------------------------------------------------------------
require("mason-lspconfig").setup({
    ensured_installed = servers,
    automatic_installation = true,
})
-- Setup LSP server
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local function on_attach(client, bufnr)
    if client.name == "ruff_lsp" then
        client.server_capabilities.hoverProvider = false
    end
    local opts = { noremap = true, buffer = bufnr }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gy", vim.lsp.buf.type_definition, opts)
end

local lspconfig = require("lspconfig")
for _, server in ipairs(servers) do
    lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end
-- Setup completion
local cmp = require("cmp")
cmp.setup({
    completion = {
        autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged }
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<Esc>"] = cmp.mapping.abort(),
        ["<cr>"] = cmp.mapping.confirm({ select = true }),
    }),
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
    })
})


lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
    lsp.diagnostic.on_publish_diagnostics,
    {
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        underline = true,
    }
)
