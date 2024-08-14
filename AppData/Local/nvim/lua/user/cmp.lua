---------------------------------------------------------------
-- => hrsh7th/nvim-cmp
-- => hrsh7th/cmp-nvim-lsp
-- => neovim/nvim-lspconfig
---------------------------------------------------------------
local ok, cmp = pcall(require, "cmp")
if not ok then
    return
end

---------------------------------------------------------------
-- => hrsh7th/nvim-cmp
---------------------------------------------------------------
cmp.setup({
    completion = {
        autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged }
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<Esc>"] = cmp.mapping.abort(),
        ["<cr>"] = cmp.mapping.confirm({ select = true }),
    }),
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
    })
})
