"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sections
" => General
" => VIM user interface
" => Colors and Fonts
" => Files, backups, and undos
" => Text, tab and indent related
" => Editing mappings
" => Status line
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Don't try to be vi compatible
if &compatible
    set nocompatible
endif

" Set map leader to enable <leader> mappings.
" like <leader>w saves the current file
let mapleader = ' '

" Source secondary configs
source <sfile>:h/vimfiles/plugin_config.vim

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
autocmd FocusGained,BufEnter * silent! checktime

" Fast saving
nmap <leader>w :w!<cr>
nmap <leader>W :noautocmd w!<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Enable system clipboard
set clipboard^=unnamed,unnamedplus

" Set keystroke delay
set timeoutlen=500

" Disable mouse
set mouse=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set scrolloff=7

" Avoid garbled characters in Chinese language windows OS
let $LANG = 'en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,__pycache__
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
set hidden

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
set matchtime=2

" No annoying sound on errors
set noerrorbells
set visualbell
set t_vb=
autocmd GUIEnter * set visualbell t_vb=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn on syntax highlighting
syntax enable

" 24-bit colors 
if has('termguicolors') && v:version > 802
    set termguicolors
endif

set background=dark
try
    let g:material_theme_style = 'default'
    colorscheme material
catch
endtry

highlight ColorColumn ctermbg=0 guibg=#000000
highlight LineNr ctermfg=8 guifg=DarkGrey
highlight WildMenu ctermfg=237 guifg=#3a3a3a
highlight TabLineFill ctermbg=0 guibg=#000000
highlight TabLine ctermfg=15 ctermbg=8 guifg=White guibg=DarkGrey
highlight TabLineFill ctermbg=0 guibg=#000000
highlight TabLineSel ctermfg=237 ctermbg=8 guifg=#3a3a3a guibg=DarkGrey

" Encoding
set encoding=utf-8

" Use Unix as the standard file type
set fileformats=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off
set nobackup
set nowritebackup
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
set linebreak
set textwidth=500

set autoindent
set smartindent

" Wrap lines
set wrap

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows, and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Change vertical and horizontal split
nnoremap <C-w>\ :vsplit<cr>
nnoremap <C-w>- :split<cr>
nnoremap <leader>. <C-w><C-w>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using CTRL+[jk]
nnoremap <C-j> :move .+1<cr>==
nnoremap <C-k> :move .-2<cr>==
inoremap <C-j> <Esc>:move .+1<cr>==gi
inoremap <C-k> <Esc>:move .-2<cr>==gi
vnoremap <c-j> :move '>+1<cr>gv=gv
vnoremap <C-k> :move '<-2<cr>gv=gv

" Navigate tabs
nnoremap H :tabprevious<cr>
nnoremap L :tabnext<cr>

" Delete trailing white space on save, useful for some filetypes ;)
function! CleanExtraSpaces()
  let cursor = getpos('.')
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', cursor)
  call setreg('/', old_query)
endfun

autocmd BufWritePre *.txt,*.js,*.py,*.sh :call CleanExtraSpaces()

" Security
set modelines=0

" Change d to be delete without copying to buffer
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d
vnoremap D "_D

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Hide mode display in the last line
set noshowmode

" Map current mode
let s:mode_to_text = {
\   'n': 'N',
\   'v': 'V',
\   'V': 'V-L',
\   "\<C-V>": 'V-B',
\   'i': 'I',
\   'R': 'R',
\   'Rv':'V-R',
\   'c': 'C',
\}

" Format the status line
set statusline=
" Set highlight for mode
set statusline+=%#StatusLineTerm#
" Show current mode
set statusline+=\ %{toupper(GetCurrentModeText())}\ 
" Show paste mode
set statusline+=%{HasPaste()}
" Set default color
set statusline+=%*
" Show full file path (truncate start if too long)
set statusline+=\ %<%F\ 
" Show readonly
set statusline+=%r
" Show modified
set statusline+=%m
" Flush right
set statusline+=%=
" Set highlight for encoding group
set statusline+=%#ToolbarLine#
" Show filetype
set statusline+=\ %{GetFiletype()}\ \|
" Show encoding
set statusline+=\ %{GetEncoding()}\ \|
" Show line and column
set statusline+=\ %l:%c\ 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetCurrentModeText()
    let curr_mode = mode()
    return get(s:mode_to_text, curr_mode, curr_mode)
endfunction

function! GetEncoding()
    return (&fileencoding ? &fileencoding : &encoding) . (&bomb ? '-BOM' : '')
endfunction

function! GetFiletype()
    return &filetype == '' ? 'none' : &filetype
endfunction

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

function! HasPaste()
    return &paste ? '[P] ' : ''
endfunction