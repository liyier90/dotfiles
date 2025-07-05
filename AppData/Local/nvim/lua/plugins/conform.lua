return {
  "stevearc/conform.nvim",
  tag = "v9.0.0",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = { "eslint_d" },
      lua = { "stylua" },
      python = { "ruff_format", "ruff_organize_imports" },
      rust = { "rustfmt" },
      yaml = { "yamlfmt" },
    },
  },
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)

    local group = vim.api.nvim_create_augroup("MMBConform", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = group,
      pattern = "*",
      desc = "Format on save",
      callback = function(args)
        conform.format({
          timeout_ms = 1000,
          bufnr = args.buf,
          async = false,
          lsp_format = "fallback",
        })
      end,
    })
  end,
}
