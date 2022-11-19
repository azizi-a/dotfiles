
set shiftwidth=4
set autoindent
set hlsearch                " highlight search 
set number                  " add line numbers
set relativenumber          " add relative line numbers
set wildmenu                " get bash-like tab completions
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set termguicolors

" Plugins
filetype plugin on
source $HOME/.config/nvim/vim-plug/plugins.vim

" Colorscheme
" colorscheme dracula
colorscheme onedark

" Keymaps
" Press i to enter insert mode, and ii to exit insert mode.
:inoremap jj <Esc>
:inoremap kk <Esc>
" :vnoremap jk <Esc>
" :vnoremap kj <Esc>

