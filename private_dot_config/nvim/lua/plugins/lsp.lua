local function has_words_before()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

vim.filetype.add({
  pattern = {
    [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
    [".*/.github/workflows/.*%. yaml"] = "yaml.ghaction",
  },
})

vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

return {
  {
    "seblyng/roslyn.nvim",
    commit = "24f7c91ee5e09c63104deaab68f932620f25c24a",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    lazy = true,
    ft = "cs",
    opts = {
      filewatching = "roslyn",
    },
  },
  {
    "mason-org/mason.nvim",
    tag = "v2.0.0",
    lazy = true,
    cmd = "Mason",
    opts = {
      max_concurrent_installers = 1,
      registries = {
        "github:Crashdummyy/mason-registry",
        "github:mason-org/mason-registry",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    tag = "v2.3.0",
    lazy = true,
    config = function()
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
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "basedpyright",
        "lua_ls",
        "ruff",
        "rust_analyzer",
        "ts_ls",
      },
      automatic_installation = true,
    },
  },
  {
    "stevearc/conform.nvim",
    commit = "619363c30309d29ffa631e67c8183f2a72caa373",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
        csharp = { "csharpier" },
        javascript = { "biome-check" },
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        typescript = { "biome-check" },
        xml = { "csharpier" },
        yaml = { "yamlfmt" },
      },
      formatters = {
        csharpier = {
          command = "csharpier",
          args = { "format", "$FILENAME" },
          stdin = false,
          require_cwd = false,
        },
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
            timeout_ms = 2000,
            bufnr = args.buf,
            async = false,
            lsp_format = "fallback",
          })
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    commit = "eab58b48eb11d7745c11c505e0f3057165902461",
    event = { "BufWritePost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        ghaction = { "actionlint" },
        lua = { "selene" },
        sh = { "shellcheck" },
      }

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
  },
  {
    "saghen/blink.cmp",
    version = "v1.10.2",
    event = "InsertEnter",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      snippets = {
        preset = "default",
      },
      sources = {
        default = { "lsp", "snippets", "buffer", "path" },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            min_keyword_length = 1,
          },
          snippets = {
            name = "Snippets",
            module = "blink.cmp.sources.snippets",
            min_keyword_length = 2,
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 3,
          },
        },
      },
      completion = {
        list = {
          selection = {
            auto_insert = false,
          },
        },
      },
      keymap = {
        preset = "none",
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<CR>"] = {
          function(cmp)
            if cmp.snippet_active({ direction = 1 }) then
              return cmp.snippet_forward()
            end
          end,
          "select_and_accept",
          "fallback",
        },

        ["<Tab>"] = {
          function(cmp)
            if cmp.is_visible() and has_words_before() then
              return cmp.select_next()
            end
          end,
          "snippet_forward",
          "fallback",
        },

        ["<S-Tab>"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.select_prev()
            end
          end,
          "snippet_backward",
          "fallback",
        },

        ["<C-j>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "scroll_documentation_up", "fallback" },
        ["<C-Space>"] = { "show", "fallback" },
        ["\\"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.hide()
            end
          end,
          "fallback",
        },
      },
    },
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
