-- Install plug.vim is not present
local site_dir = string.format("%s/site", vim.fn.stdpath("data"))
local vim_plug_file = string.format("%s/autoload/plug.vim", site_dir)
if vim.fn.empty(vim.fn.glob(vim_plug_file)) == 1 then
    vim.cmd(string.format(
        "silent !curl -fLo %s --create-dirs %s",
        vim_plug_file,
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    ))
    vim.o.runtimepath = vim.o.runtimepath
    vim.api.nvim_create_autocmd("VimEnter", {
        pattern = { "*" },
        command = "PlugInstall --sync | source $MYVIMRC",
    })
end

local Plug = vim.fn["plug#"]
-- Place plugins in $site_dir/plugged
vim.call("plug#begin", string.format("%s/plugged", site_dir))

-- Color schemes
Plug("liyier90/material.nvim", { ["branch"] = "original-colors" })

-- Commenting
Plug("preservim/nerdcommenter")

-- Load plugins when not running in VS Code
if vim.g.vscode ~= 1 then
    -- Directory navigation
    Plug("preservim/nerdtree")

    -- Fuzzy finder
    Plug("nvim-lua/plenary.nvim")
    Plug("nvim-telescope/telescope.nvim", { ["tag"] = "0.1.8" })

    -- Completion
    Plug("hrsh7th/cmp-buffer")
    Plug("hrsh7th/cmp-nvim-lsp")
    Plug("hrsh7th/cmp-path")
    Plug("hrsh7th/nvim-cmp")

    -- LSP
    Plug("neovim/nvim-lspconfig")
    Plug("williamboman/mason.nvim")
    Plug("williamboman/mason-lspconfig.nvim")

    -- Treesitter
    Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" })
end

-- Initialize plugin system
vim.call("plug#end")

---------------------------------------------------------------
-- Configure plugins
---------------------------------------------------------------
local g = vim.g
local map = vim.keymap.set
-- No remap by default
local default_opts = { noremap = true }
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
-- Mappings
map("n", "<leader>nn", ":NERDTreeToggle<cr>", default_opts)
map("n", "<leader>nb", ":NERDTreeFromBookmark<Space>", default_opts)
map("n", "<leader>nf", ":NERDTreeFind<cr>", default_opts)
