return {
  {
    "lukas-reineke/indent-blankline.nvim",
    tag = "v3.9.0",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = false,
      },
    },
    config = true,
    main = "ibl",
  },
  {
    "mammothb/smart-indent.nvim",
    dev = true,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      code_only = true,
      indent_by_ft = {
        make = {},
      },
    },
  },
}
