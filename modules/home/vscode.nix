{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # Leave the extensions directory writable so you can still install
    # things from the Open VSX marketplace by hand. Set to false if you
    # want the declared list to be the only source of truth.
    mutableExtensionsDir = true;

    # The profiles.* layout arrived in Home Manager 25.05. On older
    # releases these options sit directly under programs.vscode.
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        svelte.svelte-vscode
        pkief.material-icon-theme
        streetsidesoftware.code-spell-checker
        asvetliakov.vscode-neovim
        mkhl.direnv
        jnoortheen.nix-ide

        # Not in nixpkgs: liviuschera.noctis (your colour theme),
        # oderwat.indent-rainbow, naumovs.color-highlight.
        # Either install them from the marketplace (mutableExtensionsDir
        # is on, so they will stick), or add the nix-vscode-extensions
        # flake as an input and pull them from Open VSX declaratively.
      ];

      userSettings = {
        # --- Editor ---------------------------------------------------------
        "editor.tabSize" = 2;
        "editor.wordWrap" = "on";
        "editor.wrappingIndent" = "indent";
        "editor.formatOnSave" = true;
        "editor.fontLigatures" = true;
        "editor.fontFamily" =
          "'LigaSrc Pro', 'Fira Code', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
        "editor.renderWhitespace" = "all";
        "editor.renderLineHighlight" = "all";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.bracketPairColorization.enabled" = true;
        "editor.suggest.insertMode" = "replace";
        "editor.acceptSuggestionOnCommitCharacter" = false;
        "editor.tabCompletion" = "on";
        "editor.quickSuggestions".strings = "on";
        "editor.inlineSuggest.enabled" = true;
        "editor.inlayHints.enabled" = "offUnlessPressed";
        "editor.unicodeHighlight.ambiguousCharacters" = false;
        "editor.mouseWheelScrollSensitivity" = 0.5;

        # --- Workbench ------------------------------------------------------
        "workbench.colorTheme" = "Noctis";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.editor.labelFormat" = "short";
        "workbench.list.mouseWheelScrollSensitivity" = 0.2;
        "workbench.list.horizontalScrolling" = true;
        "workbench.list.smoothScrolling" = true;
        "workbench.colorCustomizations" = {
          editorSelection = "#FFFFFF60";
          editorSelectionHighlight = "#FFFFFF10";
        };
        "workbench.editorAssociations" = {
          "*.ipynb" = "jupyter.notebook.ipynb";
          "git-rebase-todo" = "default";
        };

        # --- Terminal -------------------------------------------------------
        "terminal.integrated.fontFamily" = "SauceCodePro Nerd Font";
        "terminal.integrated.cursorStyle" = "line";
        "terminal.integrated.mouseWheelScrollSensitivity" = 0.2;

        # --- Window ---------------------------------------------------------
        "window.menuBarVisibility" = "toggle";
        "window.zoomLevel" = 1.75;

        # --- Formatters per language ----------------------------------------
        "[css]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[markdown]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[vue]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "[svelte]"."editor.defaultFormatter" = "svelte.svelte-vscode";
        "[search-result]"."editor.lineNumbers" = "on";

        # --- Spell checker --------------------------------------------------
        "cSpell.language" = "en-GB";
        "cSpell.enableFiletypes" = [ "*" ];
        "cSpell.userWords" = [
          "Adeyemo"
          "Azizi"
          "gumball"
          "gumballs"
          "Instapass"
          "placeholder"
          "scrypto"
          "Stokenet"
          "sumsub"
          "Trustology"
          # Nix vocabulary, since you will be writing a lot of it now
          "flake"
          "nixpkgs"
          "NixOS"
          "dconf"
        ];

        # --- Neovim integration ---------------------------------------------
        # The three darwin-specific paths and the /usr/local/opt one are
        # dropped; this resolves to the exact nvim built by neovim.nix.
        "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
        "extensions.experimental.affinity"."asvetliakov.vscode-neovim" = 1;

        # --- Language tooling -----------------------------------------------
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "typescript.updateImportsOnFileMove.enabled" = "always";
        "vue.updateImportsOnFileMove.enabled" = true;
        "svelte.enable-ts-plugin" = true;
        "svelte.plugin.svelte.format.config.svelteBracketNewLine" = false;
        "emmet.includeLanguages".javascript = "javascriptreact";
        "html.format.wrapLineLength" = 80;
        "prettier.proseWrap" = "always";
        "go.toolsManagement.autoUpdate" = true;

        # Points the Nix extension at the formatter and LSP from packages.nix.
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "nixfmt";

        # --- Misc -------------------------------------------------------------
        "diffEditor.ignoreTrimWhitespace" = false;
        "diffEditor.maxComputationTime" = 0;
        "explorer.confirmDragAndDrop" = false;
        "git.openRepositoryInParentFolders" = "always";
        "zenMode.hideLineNumbers" = false;
        "liveServer.settings.donotShowInfoMsg" = true;
        "files.exclude" = {
          "**/bin" = true;
          "**/obj" = true;
        };
        "files.associations"."*.cs" = "csharp";

        # Dropped as no longer meaningful here: sync.gist (settings sync
        # is superseded by this repo), bracket-pair-colorizer-2.* (folded
        # into the editor years ago), the csharpextensions and
        # terminal.external.osxExec keys.
      };
    };
  };

  # Snippets are copied verbatim rather than translated into Nix. The
  # bodies are full of ${1:placeholder} syntax that would need escaping at
  # every occurrence, and JSON-with-comments survives the round trip
  # intact this way.
  xdg.configFile = {
    "Code/User/snippets/html.json".source = ../../config/vscode/snippets/html.json;
    "Code/User/snippets/typescript.json".source = ../../config/vscode/snippets/typescript.json;
    "Code/User/snippets/typescriptreact.json".source = ../../config/vscode/snippets/typescriptreact.json;
    "Code/User/snippets/todo.code-snippets".source = ../../config/vscode/snippets/todo.code-snippets;
    "Code/User/snippets/stories.svelte.code-snippets".source =
      ../../config/vscode/snippets/stories.svelte.code-snippets;
  };
}
