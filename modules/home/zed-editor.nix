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
      "dockerfile"
      "docker-compose"

      "codebook"

      "noctis-port"
      "material-icon-theme"
    ];

    userSettings = {
      theme = {
        mode = "dark";
        dark = "Noctis";
        light = "Hibernus Light";
        icon_theme = "Material Icon Theme";
      };

      buffer_font_family = "LigaSrc Pro";
      buffer_font_size = 14;
      buffer_font_features.calt = true; # ligatures
      ui_font_family = "LigaSrc Pro";
      ui_font_size = 14;

      tab_size = 2;
      format_on_save = "on";
      soft_wrap = "editor_width";
      preferred_line_length = 80;
      show_whitespaces = "all";
      cursor_blink = false;

      base_keymap = "VSCode";
      vim_mode = true;

      terminal = {
        font_family = "SauceCodePro Nerd Font";
        font_size = 14;
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
          arguments = [
            "--stdin-filepath"
            "{buffer_path}"
          ];
        };
        TSX.formatter.external = {
          command = "prettier";
          arguments = [
            "--stdin-filepath"
            "{buffer_path}"
          ];
        };
        Svelte.formatter.external = {
          command = "prettier";
          arguments = [
            "--stdin-filepath"
            "{buffer_path}"
          ];
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
