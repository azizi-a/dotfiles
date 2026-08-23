{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    # Zed installs extensions itself at first launch; Home Manager writes
    # these into auto_install_extensions in settings.json. An unknown id
    # is a silent no-op rather than a build failure.
    extensions = [
      "nix"
      "toml"
      "svelte"
      "html"

      # There is a Noctis port in the Zed extension registry, but I could
      # not confirm the exact slug. If the theme does not appear after
      # first launch, open the command palette, run `zed: extensions`,
      # search Noctis, and correct the id here and in `theme` below.
      "noctis"
    ];

    userSettings = {
      theme = {
        mode = "dark";
        dark = "Noctis";
        light = "One Light";
      };

      # Same fonts as VSCode, so the two look consistent side by side.
      buffer_font_family = "LigaSrc Pro";
      buffer_font_size = 14;
      buffer_font_features.calt = true; # ligatures
      ui_font_family = "Fira Code";
      ui_font_size = 15;

      # From your VSCode settings.
      tab_size = 2;
      format_on_save = "on";
      soft_wrap = "editor_width";
      preferred_line_length = 80;
      show_whitespaces = "all";
      relative_line_numbers = true;
      cursor_blink = false;

      # You drive VSCode through vscode-neovim, so this is almost
      # certainly what you want. Flip to false if Zed is your "normal
      # editing" editor.
      vim_mode = true;

      terminal = {
        font_family = "SauceCodePro Nerd Font";
        font_size = 13;
        shell.program = "${pkgs.zsh}/bin/zsh";
      };

      # Zed's inline assistant talks to Anthropic by default; leaving the
      # explicit block here so the choice is visible rather than implicit.
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      languages = {
        TypeScript.formatter.external = {
          command = "prettier";
          arguments = [ "--stdin-filepath" "{buffer_path}" ];
        };
        TSX.formatter.external = {
          command = "prettier";
          arguments = [ "--stdin-filepath" "{buffer_path}" ];
        };
        Svelte.formatter.external = {
          command = "prettier";
          arguments = [ "--stdin-filepath" "{buffer_path}" ];
        };
        Nix = {
          language_servers = [ "nixd" ];
          formatter.external.command = "nixfmt";
        };
      };

      lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
    };

    extraPackages = with pkgs; [
      nixd
      nixfmt
      prettier
      typescript-language-server
    ];
  };
}
