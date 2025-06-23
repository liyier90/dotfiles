return {
  "stevearc/conform.nvim",
  tag = "v9.0.0",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      yaml = { "yamlfmt" },
    },
  },
  config = true,
}
