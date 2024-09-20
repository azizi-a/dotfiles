" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')
 Plug 'sheerun/vim-polyglot'    " Better syntax support
 Plug 'scrooloose/NERDTree'     " File explorer
 Plug 'jiangmiao/auto-pairs'    " Auto pairs for '(' '[' '{' '''
 Plug 'talha-akram/noctis.nvim' " Theme
 Plug 'ryanoasis/vim-devicons'  " Devicon support for nerdtree
 Plug 'preservim/nerdcommenter' " Easy way for commenting out lines
 Plug 'mhinz/vim-startify'      " Handy start page with lots of customizations
 Plug 'neoclide/coc.nvim', {'branch': 'release'} "Fast code completion engine
 Plug 'norcalli/nvim-colorizer.lua' " colourize any colour variables
 Plug 'itchyny/lightline.vim'   " Statusline/tabline
call plug#end()

" load all files in plugin-configs/
for file in split(glob('~/.config/nvim/vim-plug/plugin-configs/*'), '\n')
  exe 'source' file
endfor
