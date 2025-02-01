return {
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "storm",
                plugins = {
                    "nvim-cmp",
                    "telescope",
                },
            })
            vim.cmd("colorscheme tokyonight")

            vim.cmd("highlight ColorColumn ctermbg=0 guibg=Black")
            vim.cmd("highlight LineNr ctermfg=8 guifg=DarkGrey")
        end,
    },
}
