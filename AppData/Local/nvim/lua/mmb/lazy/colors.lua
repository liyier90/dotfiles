return {
    {
        "folke/tokyonight.nvim",
        tags = "v4.11.0",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "storm",
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                },
                on_highlights = function(highlights, colors)
                    highlights.DiagnosticUnderlineError.undercurl = nil
                    highlights.DiagnosticUnderlineError.underline = true
                end,
                cache = true,
                plugins = {
                    cmp = true,
                    telescope = true,
                    treesitter = true,
                },
            })
            vim.cmd("colorscheme tokyonight")

            vim.cmd("highlight ColorColumn ctermbg=0 guibg=Black")
            vim.cmd("highlight LineNr ctermfg=8 guifg=DarkGrey")
        end,
    },
}
