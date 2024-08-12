local g = vim.g
local map = vim.keymap.set

-- Install plug.vim is not present
local data_dir = string.format("%s/site", vim.fn.stdpath("data"))
local vim_plug_file = string.format("%s/autoload/plug.vim", data_dir)
if vim.fn.empty(vim.fn.glob(vim_plug_file)) == 1 then
    vim.cmd(string.format(
        "silent !curl -fLo %s --create-dirs %s",
        vim_plug_file,
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    ))
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
        pattern = { "*" },
        command = "PlugInstall --sync | source $MYVIMRC",
    })
end

local Plug = vim.fn["plug#"]
-- Place plugins in $data_dir/plugged
vim.call("plug#begin", string.format("%s/plugged", data_dir))

Plug("hrsh7th/nvim-cmp")
Plug("hrsh7th/cmp-nvim-lsp")
Plug("kaicataldo/material.vim", { ["branch"] = "main" })
Plug("neovim/nvim-lspconfig")
Plug("preservim/nerdcommenter")
Plug("preservim/nerdtree")
Plug("williamboman/mason.nvim")
Plug("williamboman/mason-lspconfig.nvim")

-- Initialize plugin system
vim.call("plug#end")

---------------------------------------------------------------
-- => preservim/nerdcommenter
---------------------------------------------------------------
-- Create default mappings
g.NERDCreateDefaultMappings = 1
-- Use compact syntax for prettified multi-line comments
g.NERDCompactSexyComs = 1
-- Allow commenting and inverting empty lines
g.NERDCommentEmptyLines = 1
-- Align line-wise comment delimiters flush left instead of following code indentation
g.NERDDefaultAlign = "left"
-- Add spaces after comment delimiters by default
g.NERDSpaceDelims = 1
-- Enable NERDCommenterToggle to check all selected lines is commented or not 
g.NERDToggleCheckAllLines = 1
-- Enable trimming of trailing whitespace when uncommenting
g.NERDTrimTrailingWhitespace = 1

---------------------------------------------------------------
-- => preservim/nerdtree
---------------------------------------------------------------
-- Put the NERDTree window on the left
g.NERDTreeWinPos = "left"
g.NERDTreeWinSize = 35
-- Closes NERDTree window after open a file
g.NERDTreeQuitOnOpen = 1
-- Ignore files filtered by wildignore
g.NERDTreeRespectWildIgnore = 1
g.NERDTreeShowHidden = 0
map("n", "<leader>nn", ":NERDTreeToggle<cr>", { noremap = true })
map("n", "<leader>nb", ":NERDTreeFromBookmark<Space>", { noremap = true })
map("n", "<leader>nf", ":NERDTreeFind<cr>", { noremap = true})

---------------------------------------------------------------
-- => hrsh7th/nvim-cmp
-- => hrsh7th/cmp-nvim-lsp
-- => neovim/nvim-lspconfig
-- => williamboman/mason.nvim
-- => williamboman/mason-lspconfig.nvim
---------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
    ensured_installed = { "basedpyright" },
})
-- Setup LSP server
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local function on_attach(client, bufnr)
    local opts = { noremap = true, buffer = bufnr }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gy", vim.lsp.buf.type_definition, opts)
end

local lspconfig = require("lspconfig")
local servers = { "basedpyright" }
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
