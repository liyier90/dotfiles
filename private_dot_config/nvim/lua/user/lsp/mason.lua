---------------------------------------------------------------
-- => williamboman/mason.nvim
-- => williamboman/mason-lspconfig.nvim
-- => neovim/nvim-lspconfig
---------------------------------------------------------------
local lsp = vim.lsp
local map = vim.keymap.set
local servers = {
    "basedpyright",
    "ruff",
    -- "ruff_lsp",
}

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

---------------------------------------------------------------
-- => neovim/nvim-lspconfig
---------------------------------------------------------------
local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
    return
end

for _, server in ipairs(servers) do
    local opts = {
        capabilities = require("user.lsp.handlers").capabilities,
        on_attach = require("user.lsp.handlers").on_attach,
    }
    server = vim.split(server, "@")[1]
	local ok, conf_opts = pcall(require, string.format("user.lsp.settings.%s", server))
    if ok then
        opts = vim.tbl_deep_extend("force", conf_opts, opts)
    end
    lspconfig[server].setup(opts)
end

