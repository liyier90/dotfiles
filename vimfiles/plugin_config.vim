" Install plug.vim is not present
let s:data_dir = expand($HOME) . (has('unix') ? '/.vim' : '/vimfiles')
if empty(glob(s:data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo ' . s:data_dir . '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $HOME/_vimrc
endif

" Place plugins in $data_dir/plugged
call plug#begin(s:data_dir . '/plugged')

Plug 'bfrg/vim-cpp-modern', { 'branch': 'master' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'branch': 'master' }
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'rhysd/vim-clang-format', { 'branch': 'master' }
Plug 'rust-lang/rust.vim'
Plug 'vim-python/python-syntax', { 'branch': 'master' }
if has('patch-9.0.0438')
    Plug 'neoclide/coc.nvim', { 'branch': 'release' }
endif

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => junegunn/fzf.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bind ctrl-a:select-all and ctrl-d:deselect-all with Ag. Show preview.
" Ag Vim function:
" fzf#vim#ag(query, ag options, fzf#run options, fullscreen)
autocmd VimEnter *
\   command! -bang -nargs=* Ag
\   call fzf#vim#ag(<q-args>, '',
\   fzf#vim#with_preview({'options': '--bind ctrl-a:select-all,ctrl-d:deselect-all'}), <bang>0)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => preservim/nerdcommenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Create default mappings
let g:NERDCreateDefaultMappings = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Allow commenting and inverting empty lines
let g:NERDCommentEmptyLines = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => preservim/nerdtree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Put the NERDTree window on the left
let g:NERDTreeWinPos = 'left'
let g:NERDTreeWinSize = 35
" Closes NERDTree window after open a file
let NERDTreeQuitOnOpen = 1
" Ignore files filtered by wildignore
let NERDTreeRespectWildIgnore = 1
let NERDTreeShowHidden = 0
nnoremap <leader>nn :NERDTreeToggle<cr>
nnoremap <leader>nb :NERDTreeFromBookmark<Space>
nnoremap <leader>nf :NERDTreeFind<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => rhysd/vim-clang-format
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:clang_format#code_style = 'google'
autocmd FileType c,cpp,cuda ClangFormatAutoEnable

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => rust-lang/rust.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rustfmt_autosave = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-python/python-syntax
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_highlight_all = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => neoclide/coc.nvim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:coc_global_extensions = [
\   'coc-prettier',
\   'coc-pyright',
\]

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => neoclide/coc.nvim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Milliseconds to wait after typing before triggering some plugins 
set updatetime=750

" Display signs on the column
set signcolumn=yes

" Use Tab and Shift+Tab to navigate completion menu
inoremap <silent><expr> <Tab>
\   coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <silent><expr> <S-Tab>
\   coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Use <cr> to confirm completion, `<C-g>u` breaks undo chain at current position.
" Notifies coc.nvim that <enter> has been pressed to trigger formatOnType feature.
inoremap <silent><expr> <cr>
\   coc#pum#visible() ? coc#pum#confirm() :
\   "\<C-g>u\<cr>\<C-r>=coc#on_enter()\<cr>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<cr>

function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Add `:Sort` command to organize imports of the current buffer
command! -nargs=0 Sort :call CocAction('runCommand', 'editor.action.organizeImport')

autocmd BufWritePre *.py :call FormatOnSave()

function! FormatOnSave()
    execute "Format"
    execute "Sort"
endfunction

" Configure workspace root pattern
autocmd FileType python let b:coc_root_patterns = ['.git', '.env']
