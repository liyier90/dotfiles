return {
    "stevearc/conform.nvim",
    tag = "v9.0.0",
    config = function()
        require("conform").setup({
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                yaml = { "yamlfmt" },
            },
        })
    end,
}
