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
    "mammothb/image.nvim",
    dev = true,
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      max_width_window_percentage = 80,
      max_height_window_percentage = 80,
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = "popup",
        },
      },
      debug = {
        enabled = true,
        level = "debug",
        file_path = "/tmp/image.nvim.log",
        format = "compact",
      },
    },
  },
  {
    "3rd/diagram.nvim",
    commit = "89d8110ec15021ac9a03ff2317d27b900c45bf60",
    dependencies = {
      "mammothb/image.nvim",
    },
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    tag = "v8.12.0",
    ft = { "markdown" },
    opts = {
      completions = {
        lsp = { enabled = true },
      },
    },
    config = true,
  },
}
