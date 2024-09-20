return {
    {
        -- "liyier90/material.nvim",
        -- name = "material",
        -- branch = "original-colors",
        "material.nvim",
        name = "material",
        dir = "D:/GitRepos/material.nvim",
        config = function()
            require("material").setup({
                async_loading = false,
                plugins = {
                    "nvim-cmp",
                    "telescope",
                },
            })
            vim.cmd("colorscheme material")

            vim.cmd("highlight ColorColumn ctermbg=0 guibg=Black")
            vim.cmd("highlight LineNr ctermfg=8 guifg=DarkGrey")
        end,
    },
}
