set scrolloff=2           " show lines above courser when setting view position
set incsearch             " show where search pattern matches as it's typed
set linebreak             " line break in white space where possible
set shiftwidth=2          " number of spaces used for each step of (auto)indent
set autoindent            " keeps indentation from prev line
set smartindent           " updates indenting level inside block
set hlsearch              " highlight search 
set number                " add line numbers
set wildmenu              " get bash-like tab completions
set mouse=a               " enable mouse click
set clipboard=unnamedplus " using system clipboard
set cursorline            " highlight the line the cursor is on
set list listchars=space:·,tab:⟶\ ,nbsp:+ " show spaces, tabs etc.
set textwidth=80          " wrapping column width
set colorcolumn=+1        " show textwidth
set spell spelllang=en_gb
set termguicolors

" Plugins
filetype plugin on
source $HOME/.config/nvim/vim-plug/plugins.vim

" Colour scheme
colorscheme noctis
hi SpellBad guifg=NONE
hi SpellLocal guifg=NONE

" Key maps
:let mapleader = " "
:map <silent> <leader>h :noh<CR>
:map <leader>/ <plug>NERDCommenterToggle
" :W will save with sudo and reload file
:command W ':w !sudo tee % > /dev/null' | :edit!
" Press i to enter insert mode, and jj or kk to exit insert mode.
" :inoremap jj <Esc>
" :inoremap kk <Esc>
