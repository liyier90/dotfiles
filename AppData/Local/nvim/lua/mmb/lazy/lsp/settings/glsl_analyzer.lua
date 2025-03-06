local clang_format_group = vim.api.nvim_create_augroup("ClangFormat", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = clang_format_group,
    pattern = { "*.frag" },
    command = [[ %!clang-format ]],
})
return {}
