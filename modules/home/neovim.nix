{ pkgs, lib, ... }:
let
  # The nixpkgs attribute has come and gone across releases, so `or`
  # falls back lazily. Expect a hash mismatch naming the right hash.
  noctis =
    pkgs.vimPlugins.noctis-nvim or (pkgs.vimUtils.buildVimPlugin {
      pname = "noctis-nvim";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "talha-akram";
        repo = "noctis.nvim";
        rev = "HEAD";
        hash = lib.fakeHash;
      };
    });

  pluginConfigs = ../../config/nvim/plugin-configs;
in
{
  programs.neovim = {
    enable = true;

    # coc.nvim is a Node application and needs its runtime declared.
    withNodeJs = true;
    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
      vim-polyglot # better syntax support
      nerdtree # file explorer
      auto-pairs # auto-close brackets and quotes
      noctis # theme
      vim-devicons # devicon support for nerdtree
      vim-startify # start page

      {
        plugin = nerdcommenter;
        type = "viml";
        config = builtins.readFile "${pluginConfigs}/nerd-commenter.vim";
      }

      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = builtins.readFile "${pluginConfigs}/colorizer.lua";
      }

      {
        plugin = coc-nvim;
        type = "lua";
        config = builtins.readFile "${pluginConfigs}/coc.lua";
      }

      # coc-* packages are not listed: nixpkgs keeps dropping them as
      # unmaintained. g:coc_global_extensions below installs them instead.

      # lightline calls FugitiveHead, so fugitive has to be present.
      vim-fugitive
      {
        plugin = lightline-vim;
        type = "viml";
        config = builtins.readFile "${pluginConfigs}/lightline.vim";
      }
    ];

    # What coc shells out to, on PATH for nvim only.
    extraPackages = with pkgs; [
      nixd
      typescript-language-server
      rust-analyzer
    ];

    extraConfig = ''
      " coc installs and updates these itself on first launch, into
      " ~/.config/coc/extensions. Same list as the old
      " nvim/coc/extensions/package.json. Needs network access the first
      " time you open nvim; after that it is cached.
      let g:coc_global_extensions = [
        \ 'coc-json',
        \ 'coc-tsserver',
        \ 'coc-html',
        \ 'coc-css',
        \ 'coc-rust-analyzer',
        \ ]

      set scrolloff=2           " show lines above cursor when setting view position
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

      filetype plugin on

      " Colour scheme
      colorscheme noctis
      hi SpellBad guifg=NONE
      hi SpellLocal guifg=NONE

      " Key maps
      let mapleader = " "
      map <silent> <leader>h :noh<CR>
      map <leader>/ <plug>NERDCommenterToggle
      " :W will save with sudo and reload file
      cnoremap W w !sudo tee % > /dev/null | :edit!
    '';
  };

  # Or coc-rust-analyzer downloads its own, which is dynamically linked
  # and will not run without nix-ld.
  xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON {
    "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    "tsserver.tsdk" = "${pkgs.typescript}/lib/node_modules/typescript/lib";
    "suggest.noselect" = false;
    "coc.preferences.extensionUpdateCheck" = "never";
  };
}
