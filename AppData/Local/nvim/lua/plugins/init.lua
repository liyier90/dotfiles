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
    config = function(_, opts)
      local fidget = require("fidget").setup(opts)
      vim.notify = fidget.notify
    end,
  },
}
