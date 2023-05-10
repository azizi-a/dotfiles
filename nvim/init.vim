
set shiftwidth=4
set autoindent
set hlsearch                " highlight search 
set number                  " add line numbers
set relativenumber          " add relative line numbers
set wildmenu                " get bash-like tab completions
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set termguicolors
setlocal spell spelllang=en_gb

" Plugins
filetype plugin on
source $HOME/.config/nvim/vim-plug/plugins.vim

" Colour scheme
" colorscheme dracula
colorscheme onedark

" Key maps
" Press i to enter insert mode, and jj or kk to exit insert mode.
:inoremap jj <Esc>
:inoremap kk <Esc>
" :vnoremap jk <Esc>
" :vnoremap kj <Esc>

