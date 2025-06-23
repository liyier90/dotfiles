return {
  {
    "zbirenbaum/copilot.lua",
    commit = "c1bb86abbed1a52a11ab3944ef00c8410520543d",
    lazy = true,
    cmd = "Copilot",
    opts = {
      copilot_model = "gpt-4.1",
      panel = { enabled = false },
      suggestion = { enabled = false },
      filetypes = { ["*"] = false },
    },
    config = true,
  },
  {
    "olimorris/codecompanion.nvim",
    tag = "v17.1.1",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "AI chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "AI actions" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<CR>", desc = "AI explain", mode = "v" },
    },
    opts = {
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "gpt-4.1",
              },
            },
          })
        end,
        tavily = function()
          return require("codecompanion.adapters").extend("tavily", {
            env = {
              api_key = "cmd:cat C:/Users/Admin/tavily",
            },
          })
        end,
      },
      display = {
        action_palette = {
          opts = {
            show_default_actions = true,
            show_default_prompt_library = false,
          },
        },
        chat = {
          window = {
            position = "right",
          },
        },
        diff = {
          enabled = true,
          layout = "vertial",
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "copilot",
        },
      },
    },
    config = true,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    tag = "v8.5.0",
    ft = { "markdown", "codecompanion" },
  },
}
