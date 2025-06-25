return {
  "stevearc/conform.nvim",
  tag = "v9.0.0",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    format_on_save = {
      async = true,
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      javascript = { "eslint_d" },
      lua = { "stylua" },
      yaml = { "yamlfmt" },
    },
  },
  config = true,
}
