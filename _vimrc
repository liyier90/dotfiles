" Don't try to be vi compatible
set nocompatible

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * checktime

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ','

" Fast saving
nmap <leader>w :w!<cr>
nmap <leader>W :noautocmd w!<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
set clipboard^=unnamed,unnamedplus

" Set keystroke delay
set timeoutlen=100

" Disable mouse
set mouse=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let data_dir = expand($HOME) . '/vimfiles'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $HOME/_vimrc
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin("$HOME/vimfiles/plugged")

Plug 'bfrg/vim-cpp-modern', { 'branch': 'master' }
Plug 'hashivim/vim-terraform', { 'branch': 'master' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'branch': 'master' }
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'marshallward/vim-restructuredtext'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'prettier/vim-prettier', { 'do': 'npm install --frozen-lockfile --production' }
Plug 'rhysd/vim-clang-format', { 'branch': 'master' }
Plug 'rust-lang/rust.vim'
Plug 'vim-python/python-syntax', { 'branch': 'master' }

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Avoid garbled characters in Chinese language windows OS
let $LANG = 'en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has('win16') || has('win32')
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Always show current position
set ruler
set colorcolumn=80

" Show line number
set number

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Properly disable sound on errors on MacVim
if has('gui_macvim')
    autocmd GUIEnter * set vb t_vb=
endif

" Add a bit extra margin to the left
set foldcolumn=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn on syntax highlighting
syntax on

" Color scheme (terminal)
" Enable 256 colors palette in Gnome Terminal
if (has('termguicolors'))
    set termguicolors
elseif $COLORTERM == 'gnome-terminal' || has ('win32')
    set t_Co=256
endif

set background=dark
let g:material_theme_style = 'default'
colorscheme material

if has ('win32')
    highlight ColorColumn ctermbg=238
else
    highlight ColorColumn ctermbg=0
endif
highlight LineNr ctermfg=DarkGrey
highlight WildMenu ctermfg=237 guifg=#121212
highlight TablineFill ctermbg=0 guibg=#424242
highlight TabLineSel ctermfg=237 guifg=#121212

" Encoding
set encoding=utf-8

" Use Unix as the standard file type
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

hi StatusLineNormal ctermfg=231 ctermbg=2 cterm=bold
hi StatusLineVisual ctermfg=231 ctermbg=13 cterm=bold
hi StatusLineInsert ctermfg=231 ctermbg=4 cterm=bold
hi StatusLineCommand ctermfg=231 ctermbg=6 cterm=bold
hi StatusLineReplace ctermfg=231 ctermbg=5 cterm=bold

" Map current mode
let g:currentmode = {
    \ 'n': {
        \ 'text': 'N',
        \ 'color': 'StatusLineNormal',
    \ },
    \ 'v': {
        \ 'text': 'V',
        \ 'color': 'StatusLineVisual',
    \ },
    \ 'V': {
        \ 'text': 'V-L',
        \ 'color': 'StatusLineVisual',
    \ },
    \ "\<C-V>": {
        \ 'text': 'V-B',
        \ 'color': 'StatusLineVisual',
    \ },
    \ 'i': {
        \ 'text': 'I',
        \ 'color': 'StatusLineInsert',
    \ },
    \ 'R': {
        \ 'text': 'R',
        \ 'color': 'StatusLineReplace',
    \ },
    \ 'Rv': {
        \ 'text': 'V-R',
        \ 'color': 'StatusLineReplace',
    \ },
    \ 'c': {
        \ 'text': 'C',
        \ 'color': 'StatusLineCommand',
    \ },
\ }

function GetCurrentModeColor()
    let curr_mode = mode()
    if (has_key(g:currentmode, curr_mode))
        return "%#" . g:currentmode[curr_mode]['color'] . "#"
    endif
    return "%#StatusLineTerm#"
endfunction

function GetCurrentModeText()
    let curr_mode = mode()
    if (has_key(g:currentmode, curr_mode))
        return g:currentmode[curr_mode]['text']
    endif
    return curr_mode
endfunction

function! HasPaste()
    return &paste ? '[P] ' : ''
endfunction

function! GetEncoding()
    let encoding = &fileencoding ? &fileencoding : &encoding
    let bom = &bomb ? '-BOM' : ''
    return encoding . bom
endfunction

" Format the status line
set statusline=
" Set highlight for mode
set statusline+=%{%GetCurrentModeColor()%}
" Show current mode
set statusline+=\ %{toupper(GetCurrentModeText())}\ 
" Show paste mode
set statusline+=%{HasPaste()}
" Set default color
set statusline+=%*
" Show full file path
set statusline+=\ %<%F\ 
" Show modified
set statusline+=%m
" Flush right
set statusline+=%=
" Set highlight for encoding group
set statusline+=%#ToolbarLine#
" Show filetype
set statusline+=\ %{&filetype!=#''?&filetype:'none'}\ \|
" Show encoding
set statusline+=\ %{GetEncoding()}\ \|
" Show line and column
set statusline+=\ %l:%c\ 

set noshowmode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using CTRL+[jk]
nnoremap <C-j> :m .+1<cr>==
nnoremap <C-k> :m .-2<cr>==
inoremap <C-j> <Esc>:m .+1<cr>==gi
inoremap <C-k> <Esc>:m .-2<cr>==gi
vnoremap <C-j> :m '>+1<cr>gv=gv
vnoremap <C-k> :m '<-2<cr>gv=gv

" Navigate tabs
nnoremap H gT
nnoremap L gt

function! GetVisualSelection()
    let [line_start, col_start] = getpos("'<")[1:2]
    let [line_end, col_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][:col_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col_start - 1:]
    return join(lines, "\n")
endfunction

" Delete trailing white space on save, useful for some filetypes ;)
function! CleanExtraSpaces()
  let save_cursor = getpos('.')
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfun

if has('autocmd')
  autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

" Security
set modelines=0

" Blink cursor on error instead of beeping (grr)
set visualbell

" Change d to be delete without copying to buffer
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d
vnoremap D "_D

" Change vertical and horizontal split
nnoremap <C-w>\ :vsplit<cr>
nnoremap <C-w>- :split<cr>
nnoremap <leader><leader> <C-w><C-w>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => fzf 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" query, ag options, fzf#run options, fullscreen
autocmd VimEnter *
    \ command! -bang -nargs=* Ag
    \ call fzf#vim#ag(<q-args>, '', { 'options': '--bind ctrl-a:select-all,ctrl-d:deselect-all' }, <bang>0)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => COC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nobackup
set nowritebackup

set updatetime=300

set signcolumn=yes

inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm() :
            \ "\<C-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"

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

" Format and sort
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=0 Sort   :call CocActionAsync('runCommand', 'editor.action.organizeImport')

autocmd BufWritePre *.py :call FormatOnSave() 
autocmd FileType c,cpp,cuda ClangFormatAutoEnable

function! FormatOnSave()
    call CocAction('format')
    call CocAction('runCommand', 'editor.action.organizeImport')
endfunction

" Configure workspace root pattern
autocmd FileType python let b:coc_root_patterns = ['.git', '.env']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Commenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDCreateDefaultMappings = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1
let g:NERDToggleCheckAllLines = 1
let g:NERDTrimTrailingWhitespace = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinPos = 'left'
let g:NERDTreeWinSize = 35
let NERDTreeQuitOnOpen = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let NERDTreeShowHidden = 0
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Prettier 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#config#print_width = 80
let g:prettier#config#tab_width = 2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Clang format
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:clang_format#code_style = 'google'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Rust
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rustfmt_autosave = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Python syntax 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_highlight_all = 1
