return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local actions = require("telescope.actions")
        local actions_state = require("telescope.actions.state")
        local actions_utils = require("telescope.actions.utils")

        local function open_selected(prompt_bufnr)
            local current_picker = actions_state.get_current_picker(prompt_bufnr)
            local has_multi_selection = (
                next(current_picker:get_multi_selection()) ~= nil
            )
            if not has_multi_selection then
                actions.file_edit(prompt_bufnr)
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
        -- Find in buffers
        vim.keymap.set("n", "<leader>fb", function()
            builtin.live_grep({ grep_open_files = true })
        end)
        -- Find buffers
        vim.keymap.set("n", "<leader>fB", builtin.buffers)
        -- Find files
        vim.keymap.set("n", "<leader>ff", builtin.find_files)
        -- Find all files
        vim.keymap.set("n", "<leader>fF", function()
            builtin.find_files({ follow = true, no_ignore = true, hidden = true })
        end)
        -- Grep in files
        vim.keymap.set("n", "<leader>fg", builtin.live_grep)
        -- Grep in all files
        vim.keymap.set("n", "<leader>fG", function()
            builtin.live_grep({ additional_args = { "--hidden" } })
        end)
        vim.keymap.set("n", "<leader>fr", builtin.lsp_references)
        vim.keymap.set("n", "<leader>fR", function()
            builtin.lsp_references({ additional_args = { "--hidden" } })
        end)
        -- Grep an input, followed by refinement
        vim.keymap.set("n", "<leader>fs", function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        -- Grep word under cursor
        vim.keymap.set("n", "<leader>fw", function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        -- Grep WORD under cursor
        vim.keymap.set("n", "<leader>fW", function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
    end,
}
