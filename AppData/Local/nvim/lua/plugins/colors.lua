return {
  {
    "folke/tokyonight.nvim",
    tag = "v4.11.0",
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
          highlights.ColorColumn = { bg = "Black", ctermbg = 0 }
          highlights.LineNr = { fg = "DarkGrey", ctermfg = 8 }
          highlights.DiagnosticUnderlineError = { sp = colors.error, underline = true }
          highlights.DiagnosticUnderlineWarn = { sp = colors.warning, underline = true }
          highlights.DiagnosticUnderlineInfo = { sp = colors.info, underline = true }
          highlights.DiagnosticUnderlineHint = { sp = colors.hint, underline = true }
          highlights.SpellBad = { sp = colors.error, underline = true }
          highlights.SpellCap = { sp = colors.warning, underline = true }
          highlights.SpellLocal = { sp = colors.info, underline = true }
          highlights.SpellRare = { sp = colors.hint, underline = true }
        end,
        cache = true,
        plugins = {
          auto = true,
        },
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
