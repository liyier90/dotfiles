local lazy_root = string.format("%s/lazy", vim.fn.stdpath("data"))
local lazy_path = string.format("%s/lazy.nvim", lazy_root)

if not (vim.uv or vim.loop).fs_stat(lazy_path) then
    local lazy_repo = "https://github.com/folke/lazy.nvim.git"
    local output = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazy_repo,
        lazy_path,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            {"Failed to clone lazy.nvim:\n", "ErrorMsg"},
            {output, "WarningMsg"},
            {"\nPress any key to exit..."},
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazy_path)

require("lazy").setup({
    root = lazy_root,
    spec = "mmb.lazy",
    change_detection = {notify = false},
    rocks = {enabled = false},
})
