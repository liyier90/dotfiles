vim.filetype.add({
  pattern = {
    [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
    [".*/.github/workflows/.*%. yaml"] = "yaml.ghaction",
  },
})

return {
  "mfussenegger/nvim-lint",
  commit = "eab58b48eb11d7745c11c505e0f3057165902461",
  event = { "BufWritePre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      ghaction = { "actionlint" },
      sh = { "shellcheck" },
    }

    vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

    local group = vim.api.nvim_create_augroup("MMBNvimLint", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,
      pattern = "*",
      desc = "Lint after save",
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
