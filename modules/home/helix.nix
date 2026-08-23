{ pkgs, ... }:
{
  programs.helix = {
    enable = true;

    # Set to true to export EDITOR=hx. Left off because your git
    # core.editor is codium --wait, which would then disagree with the
    # rest of the shell. Harmless either way, since git's own setting wins.
    defaultEditor = false;

    settings = {
      # Helix ships noctis as a built-in theme, so nothing needs
      # vendoring. `:theme noctis_bordo` is the warmer variant if you
      # want to try it. To override individual colours without leaving
      # Nix, use programs.helix.themes to write a theme that
      # `inherits = "noctis"`.
      theme = "noctis";

      editor = {
        # From your vimrc: number + relativenumber.
        line-number = "relative";
        cursorline = true;
        scrolloff = 2;
        mouse = true;
        true-color = true;
        color-modes = true;
        bufferline = "multiple";

        # textwidth=80 with colorcolumn=+1 in init.vim.
        text-width = 80;
        rulers = [ 81 ];

        soft-wrap = {
          enable = true;
          wrap-indicator = "";
        };

        indent-guides.render = true;

        # `set list listchars=space:·,tab:⟶,nbsp:+`
        whitespace.render = {
          space = "all";
          tab = "all";
          nbsp = "all";
          newline = "none";
        };
        whitespace.characters = {
          space = "·";
          tab = "⟶";
          nbsp = "+";
        };

        file-picker.hidden = false;
        lsp.display-messages = true;
        auto-format = true;

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        statusline = {
          left = [ "mode" "spinner" "version-control" "file-name" ];
          right = [ "diagnostics" "file-encoding" "file-line-ending" "file-type" "position" ];
        };
      };

      keys.insert = {
      };

      keys.normal = {
        # <leader>h to clear search highlight, matching init.vim. Helix
        # already uses space as leader.
        space.h = ":noh";
      };
    };

    languages = {
      language-server = {
        nixd.command = "nixd";
        typescript-language-server = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
          language-servers = [ "nixd" ];
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
        }
        {
          name = "tsx";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
        }
        {
          name = "rust";
          auto-format = true;
        }
        {
          name = "svelte";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [ "--parser" "svelte" ];
          };
        }
      ];
    };

    # Language servers and formatters, on PATH for helix only. Mirrors the
    # coc extension list from neovim.nix.
    extraPackages = with pkgs; [
      nixd
      nixfmt
      rust-analyzer
      typescript-language-server
      prettier
      vscode-langservers-extracted # html, css, json, eslint
    ];
  };
}
