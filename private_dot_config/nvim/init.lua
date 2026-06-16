require("config")
require("config.lazy")

vim.keymap.set("n", "<leader>smdc", function()
  local mermaid = require("sixel-graphics.renderers.mermaid")
  local m = require("sixel-graphics.integrations.markdown")
  local diagrams = m.query_buffer_diagrams()
  if #diagrams == 0 then
    vim.notify("sixel-graphics: no diagrams found", vim.log.levels.INFO)
    return
  end

  local opts = require("sixel-graphics.config").options.renderer_options.mermaid
  local result = mermaid.render(diagrams[1].source, opts, function(path, err)
    -- Async completion (mmdc cache miss)
    if path then
      vim.schedule(function()
        require("sixel-graphics").show_image_popup(path)
      end)
    else
      vim.notify("sixel-graphics: mmdc render failed: " .. (err or "unknown"), vim.log.levels.ERROR)
    end
  end)

  -- Sync result: cache hit → show immediately
  if result and result.file_path then
    require("sixel-graphics").show_image_popup(result.file_path)
  elseif result and result.job_id then
    vim.notify("sixel-graphics: rendering diagram via mmdc...", vim.log.levels.INFO)
  end
  -- result is nil → error already notified by render()
end, { desc = "Sixel: render first diagram via mmdc" })
