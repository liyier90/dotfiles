local map = vim.keymap.set

local M = {}

local ok, cmp_nvm_lsp = pcall(require, "cmp_nvim_lsp")
if not ok then
    M.setup = function() end
    return M
end

-- Setup LSP server
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

M.setup = function()
    vim.diagnostic.config({
        float = {
			focusable = true,
			header = "",
			prefix = "",
			source = "always",
			style = "minimal",
		},
        severity_sort = true,
        virtual_text = false,
    })
end

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, buffer = bufnr }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gy", vim.lsp.buf.type_definition, opts)
    map("n", "K",  vim.lsp.buf.hover, opts)
end

M.on_attach = function(client, bufnr)
    if client.name == "ruff_lsp" then
        client.server_capabilities.hoverProvider = false
    end

    lsp_keymaps(bufnr)
end

return M
