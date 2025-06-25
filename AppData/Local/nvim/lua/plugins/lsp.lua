local function has_words_before()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

return {
  {
    "mason-org/mason.nvim",
    tag = "v2.0.0",
    lazy = true,
    cmd = "Mason",
    opts = {
      max_concurrent_installers = 1,
    },
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    tag = "v2.3.0",
    lazy = true,
    config = function()
      vim.lsp.config("*", {
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      })
      vim.diagnostic.config({
        float = {
          focusable = false,
          border = "rounded",
          header = "",
          prefix = "",
          source = true,
          style = "minimal",
        },
        severity_sort = true,
        underline = true,
        virtual_text = false,
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    tag = "v2.0.0",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "j-hui/fidget.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "basedpyright",
        "gopls",
        "jinja_lsp",
        "lua_ls",
        "ruff",
        "rust_analyzer",
      },
      automatic_installation = true,
    },
    config = true,
  },
  {
    "hrsh7th/nvim-cmp",
    tag = "v0.0.2",
    dependencies = {
      { "hrsh7th/cmp-buffer", commit = "b74fab3656eea9de20a9b8116afa3cfc4ec09657" },
      { "hrsh7th/cmp-nvim-lsp", commit = "a8912b88ce488f411177fc8aed358b04dc246d7b" },
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local select_behavior = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item(select_behavior)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_behavior)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item(select_behavior)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_behavior)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["\\"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
}
