return {
  {
    "nvim-lua/plenary.nvim",
    commit = "74b06c6c75e4eeb3108ec01852001636d85a932b",
    lazy = true,
  },
  {
    "j-hui/fidget.nvim",
    tag = "v2.0.0",
    opts = {
      notification = {
        override_vim_notify = true,
        window = {
          winblend = 0,
        },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
  },
}
