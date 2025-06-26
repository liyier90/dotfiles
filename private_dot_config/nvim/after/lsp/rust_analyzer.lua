-- local rust_analyzer_group = vim.api.nvim_create_augroup("RustAnalyzer", {})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = rust_analyzer_group,
--   pattern = { "*.rs" },
--   callback = function(_)
--     vim.lsp.buf.format({
--       async = false,
--       timeout_ms = 200,
--     })
--   end,
-- })

return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        extraEnv = {
          ["RUST_BACKTRACE"] = "0",
        },
      },
    },
  },
}
