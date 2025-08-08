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
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    lazy = true,
    config = function()
      vim.lsp.config("*", {
        capabilities = vim.tbl_deep_extend(
          "force",
          vim.lsp.protocol.make_client_capabilities(),
          require("cmp_nvim_lsp").default_capabilities()
        ),
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
      "L3MON4D3/LuaSnip",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local select_behavior = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping({
            i = function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                if luasnip.expandable() then
                  luasnip.expand()
                else
                  cmp.confirm({ select = false })
                end
              else
                fallback()
              end
            end,
            s = cmp.mapping.confirm({ select = true }),
            c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item(select_behavior)
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_behavior)
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-j>"] = cmp.mapping.scroll_docs(4),
          ["<C-k>"] = cmp.mapping.scroll_docs(-4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["\\"] = cmp.mapping.close(),
        }),
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            -- vim.snippet.expand(args.body)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", keyword_length = 1 },
          { name = "luasnip", keyword_length = 2 },
        }, {
          { name = "buffer", keyword_length = 3 },
        }),
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    tag = "v2.4.0",
    dependencies = {
      { "rafamadriz/friendly-snippets", commit = "572f5660cf05f8cd8834e096d7b4c921ba18e175" },
    },
    lazy = true,
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      local luasnip = require("luasnip")
      luasnip.setup({
        cut_selection_keys = "<Tab>",
        enable_autosnippets = true,
      })
    end,
    build = "sh -c 'CC=gcc make install_jsregexp'",
  },
}
