return {
  {
    "nvim-lua/plenary.nvim",
    commit = "857c5ac632080dba10aae49dba902ce3abf91b35",
    lazy = true,
  },
  {
    "j-hui/fidget.nvim",
    tag = "v1.6.1",
    lazy = true,
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
    config = true,
  },
  {
    "mammothb/smart-indent.nvim",
    dev = true,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      code_only = true,
    },
    config = true,
  },
}
