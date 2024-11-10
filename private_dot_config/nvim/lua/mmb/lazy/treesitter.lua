-- Cannot be lazy loaded
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        require("nvim-treesitter.configs").setup({
            auto_install = false,
            ensure_installed = { "python" },
            highlight = { enable = true },
            sync_install = true,
        })
    end,
}

