return {
    "nvim-telescope/telescope.nvim",
    name = "telescope",
    tag = "0.1.5",
    dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
        require("telescope").setup({
            defaults = {
                path_display = {"smart"},
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
                extensions = {},
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
            },
        })

        local builtin = require("telescope.builtin")
        -- Find in buffers
        vim.keymap.set("n", "<leader>fb", function()
            builtin.live_grep({grep_open_files = true})
        end)
        -- Find buffers
        vim.keymap.set("n", "<leader>fB", builtin.buffers)
        -- Find files
        vim.keymap.set("n", "<leader>ff", builtin.find_files)
        -- Find all files
        vim.keymap.set("n", "<leader>fF", function()
            builtin.find_files({follow = true, no_ignore = true, hidden = true})
        end)
        -- Grep in files
        vim.keymap.set("n", "<leader>fg", builtin.live_grep)
        -- Grep in all files
        vim.keymap.set("n", "<leader>fG", function()
            builtin.live_grep({additional_args = {"--hidden"}})
        end)
        -- Grep word under cursor
        vim.keymap.set("n", "<leader>fw", function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({search = word})
        end)
        -- Grep WORD under cursor
        vim.keymap.set("n", "<leader>fW", function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({search = word})
        end)
        -- Grep an input, followed by refinement
        vim.keymap.set("n", "<leader>fs", function()
            builtin.grep_string({search = vim.fn.input("Grep > ")})
        end)
    end,
}
