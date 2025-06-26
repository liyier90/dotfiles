return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local actions = require("telescope.actions")
    local actions_state = require("telescope.actions.state")
    local actions_utils = require("telescope.actions.utils")

    local function open_selected(prompt_bufnr)
      local current_picker = actions_state.get_current_picker(prompt_bufnr)
      local has_multi_selection = next(current_picker:get_multi_selection()) ~= nil
      if not has_multi_selection then
        actions.select_default(prompt_bufnr)
        return
      end

      local file_paths = {}
      actions_utils.map_selections(prompt_bufnr, function(selection)
        table.insert(file_paths, selection[1])
      end)

      for _, path in ipairs(file_paths) do
        vim.cmd.badd({ args = { string.match(path, "([^:]+)") } })
      end

      actions.send_selected_to_qflist(prompt_bufnr)
      actions.open_qflist()
    end

    require("telescope").setup({
      defaults = {
        extensions = {},
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Tab>"] = actions.toggle_selection,
            ["<CR>"] = open_selected,
          },
          n = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Tab>"] = actions.toggle_selection,
            ["<CR>"] = open_selected,
          },
        },
        path_display = { "smart" },
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",
            "--files",
            "--color=never",
            "--no-heading",
            "--line-number",
            "--column",
            "--smart-case",
            "--path-separator",
            "/",
          },
        },
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--path-separator",
        "/",
        "--trim",
      },
    })

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>fb", function()
      builtin.live_grep({ grep_open_files = true })
    end, { desc = "Find in buffers" })
    vim.keymap.set("n", "<leader>fB", builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fF", function()
      builtin.find_files({ follow = true, no_ignore = true, hidden = true })
    end, { desc = "Find all files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
    vim.keymap.set("n", "<leader>fG", function()
      builtin.live_grep({ additional_args = { "--hidden" } })
    end, { desc = "Grep all files" })
    vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Find references" })
    vim.keymap.set("n", "<leader>fR", function()
      builtin.lsp_references({ additional_args = { "--hidden" } })
    end, { desc = "Find all references" })
    vim.keymap.set("n", "<leader>fs", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end, { desc = "Grep input" })
    vim.keymap.set("n", "<leader>fw", function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end, { desc = "Grep <cword>" })
    vim.keymap.set("n", "<leader>fW", function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end, { desc = "Grep <cWORD>" })
  end,
}
