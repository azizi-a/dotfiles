{ pkgs, lib, ... }:
let
  # noctis-nvim is usually in nixpkgs, but the attribute has come and gone
  # over releases. `or` makes the fallback lazy, so the build below is only
  # evaluated if the attribute is genuinely missing. If that happens you
  # will get a hash mismatch error that prints the correct hash to paste in.
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

    # coc.nvim is a Node application, so its runtime has to be declared.
    # This replaces the nvim/coc/extensions/package.json dance.
    withNodeJs = true;
    withPython3 = true;

    # Plugins are installed by Nix, so vim-plug is gone entirely: no
    # autoload/plug.vim in the repo, no curl bootstrap, and no
    # `:PlugInstall` step in the README. Each plugin carries its own
    # config, which is roughly what plugin-configs/ was already doing.
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

      # The coc-* extension packages are deliberately NOT listed here.
      # nixpkgs has been dropping them as unmaintained (coc-tsserver went
      # first), and pinning the rest just queues up the same error one
      # attribute at a time. They are installed by coc itself instead,
      # via g:coc_global_extensions in extraConfig below, which is the
      # mechanism coc is designed around and which mirrors what
      # nvim/coc/extensions/package.json did on Ubuntu.

      # lightline.vim's config calls FugitiveHead, which needs fugitive
      # to be installed. It was missing from the Ubuntu plugin list, so
      # the git branch segment was silently blank.
      vim-fugitive
      {
        plugin = lightline-vim;
        type = "viml";
        config = builtins.readFile "${pluginConfigs}/lightline.vim";
      }
    ];

    # Language servers and formatters that coc and friends shell out to.
    # On Ubuntu these came from npm -g; here they are on PATH for nvim only.
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

  # coc reads this from next to init.vim. It matters on NixOS because
  # coc-rust-analyzer would otherwise download its own rust-analyzer
  # binary, which is dynamically linked and will not run without
  # programs.nix-ld. Pointing it at the nixpkgs one avoids that entirely.
  xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON {
    "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    "tsserver.tsdk" = "${pkgs.typescript}/lib/node_modules/typescript/lib";
    "suggest.noselect" = false;
    "coc.preferences.extensionUpdateCheck" = "never";
  };
}
