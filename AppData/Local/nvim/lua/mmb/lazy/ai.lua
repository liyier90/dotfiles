return {
  {
    "mammothb/copilot-auth.nvim",
    cmd = "CopilotAuth",
    event = "InsertEnter",
    config = true,
    dev = true,
  },
  {
    "zbirenbaum/copilot.lua",
    commit = "c1bb86abbed1a52a11ab3944ef00c8410520543d",
    cmd = "Copilot",
    event = "InsertEnter",
    config = true,
    opts = {
      copilot_model = "gpt-4.1",
      panel = { enabled = false },
      suggestion = { enabled = false },
      filetypes = { ["*"] = false },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    tag = "v16.3.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "echasnovski/mini.pick", tag = "v0.16.0" },
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "AI chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "AI actions" },
      { "<leader>ae", "<cmd>CodeCompanion /explain<CR>", desc = "AI explain", mode = "v" },
    },
    config = true,
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
          provider = "mini_pick",
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
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    tag = "v8.5.0",
    ft = { "markdown", "codecompanion" },
  },
}
