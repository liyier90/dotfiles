local Spinner = { id_to_handle = {} }

function Spinner:init()
  local group = vim.api.nvim_create_augroup("MMBCodeCompanionSpinner", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestStarted",
    group = group,
    callback = function(request)
      local handle = self:create_progress_handle(request)
      self:insert_progress_handle(request.data.id, handle)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestFinished",
    group = group,
    callback = function(request)
      local handle = self:remove_progress_handle(request.data.id)
      if handle then
        self:report_exit_status(request, handle)
        handle:finish()
      end
    end,
  })
end

function Spinner:create_progress_handle(request)
  return require("fidget.progress").handle.create({
    title = "",
    message = "Sending ...",
    lsp_client = {
      name = self:format(request.data.adapter),
    },
  })
end

function Spinner:insert_progress_handle(id, handle)
  self.id_to_handle[id] = handle
end

function Spinner:remove_progress_handle(id)
  local handle = self.id_to_handle[id]
  self.id_to_handle[id] = nil
  return handle
end

function Spinner:format(adapter)
  local parts = { adapter.formatted_name }
  if adapter.model and adapter.model ~= "" then
    table.insert(parts, string.format("(%s)", adapter.model))
  end
  return table.concat(parts, " ")
end

function Spinner:report_exit_status(request, handle)
  if request.data.status == "success" then
    handle.message = "Completed"
  elseif request.data.status == "error" then
    handle.message = "Error"
  else
    handle.message = "Cancelled"
  end
end

return {
  {
    "zbirenbaum/copilot.lua",
    commit = "0f2fd3829dd27d682e46c244cf48d9715726f612",
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
    tag = "v17.13.0",
    dependencies = {
      "j-hui/fidget.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "AI chat", mode = { "n", "v" } },
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "AI actions", mode = { "n", "v" } },
    },
    init = function()
      Spinner:init()
    end,
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
      },
      display = {
        action_palette = {
          opts = {
            show_default_actions = true,
          },
        },
        chat = {
          fold_context = true,
          window = {
            position = "right",
          },
        },
        diff = {
          enabled = true,
          layout = "vertical",
        },
      },
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
        cmd = { adapter = "copilot" },
      },
    },
    config = true,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    tag = "v8.6.0",
    ft = { "markdown", "codecompanion" },
    opts = {
      completions = {
        lsp = { enabled = true },
      },
    },
    config = true,
  },
}
