set scrolloff=4							" show lines above courser when setting view position
set incsearch								" show where search pattern matches as it's typed
set linebreak								" line break in white space where possible
set shiftwidth=2						" Number of spaces to use for each step of (auto)indent
set autoindent							" keeps indentation from prev line
set smartindent							" updates indenting level inside block
set hlsearch                " highlight search 
set number                  " add line numbers
" set relativenumber          " add relative line numbers
set wildmenu                " get bash-like tab completions
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set termguicolors
set spell spelllang=en_gb

" Plugins
filetype plugin on
source $HOME/.config/nvim/vim-plug/plugins.vim

" Colour scheme
colorscheme noctis_obscuro

" Key maps
" Press i to enter insert mode, and jj or kk to exit insert mode.
" :inoremap jj <Esc>
" :inoremap kk <Esc>
" :vnoremap jk <Esc>
" :vnoremap kj <Esc>
