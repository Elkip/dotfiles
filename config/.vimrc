"" -- Options --
try 
    colorscheme torte
catch
endtry
set background=dark
" Lang / encoding settings
let $LAND='en'
set langmenu=en
set encoding=utf8
set ffs=unix
" How many lines to remember
set history 500
" Wrap lines on 500 characters
set lbr
set tw=500
set wrap
" Show current position
set ruler
" Wild menu
set wildmenu
" Enable filetype plugins
syntax enable
filetype plugin on
filetype indent on
set ai " Auto indent
set si " Smart indent
" Set tab to 4 spaces
set tabstop=4
set shiftwidth=4
set expandtab
" Show context around cursor
set scrolloff=5
" Set incremental searching
set incsearch
" linenumber or relative number
set nu
" display commands at the bottom of the screen
set showmode
set showcmd
" Turn visual bell off
set visualbell
set noerrorbells
" Search options
set smartcase " ignorecase if all lower
set hlsearch " Highlight results
" System clipboard
set clipboard+=unnamed
"" -- Keybindings--
" Leader key
let mapleader = " "
