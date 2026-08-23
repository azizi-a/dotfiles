{ lib, ... }:
{
  programs.starship = {
    enable = true;
    # Replaces `eval "$(starship init zsh)"` in zshrc, and
    # install-scripts/starship.sh which piped a shell script off the web.
    enableZshIntegration = true;

    # Home Manager serialises this to ~/.config/starship.toml.
    settings = {
      # The original used a TOML multi-line string with trailing
      # backslashes, which TOML strips. A list joined into one string is
      # the same value and easier to reorder.
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$localip"
        "$shlvl"
        "$singularity"
        "$directory"
        "$kubernetes"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$hg_branch"
        "$docker_context"
        "$package"
        "$buf"
        "$c"
        "$cmake"
        "$cobol"
        "$container"
        "$daml"
        "$dart"
        "$deno"
        "$dotnet"
        "$elixir"
        "$elm"
        "$erlang"
        "$golang"
        "$haskell"
        "$helm"
        "$java"
        "$julia"
        "$kotlin"
        "$lua"
        "$nim"
        "$nodejs"
        "$ocaml"
        "$perl"
        "$php"
        "$pulumi"
        "$purescript"
        "$python"
        "$rlang"
        "$red"
        "$ruby"
        "$rust"
        "$scala"
        "$swift"
        "$terraform"
        "$vlang"
        "$vagrant"
        "$zig"
        "$nix_shell"
        "$conda"
        "$spack"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$openstack"
        "$azure"
        "$env_var"
        "$crystal"
        "$custom"
        "$sudo"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$shell"
        "$character"
      ];

      continuation_prompt = "▸";

      battery = {
        disabled = true;
        format = "[$symbol]($style)";
        display = [
          { threshold = 99; style = "bold cyan"; }
          { threshold = 98; style = "bold green"; }
          { threshold = 60; style = "bold yellow"; }
          { threshold = 30; style = "bold 214"; }
        ];
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❯](bold blue)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        home_symbol = "~";
        truncation_symbol = "…/";
        style = "bold cyan";
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        truncation_symbol = "…";
        style = "bold purple";
        disabled = false;
        symbol = " ";
      };

      git_state = {
        cherry_pick = "CHERRY PICKING";
        rebase = "REBASING";
        merge = "MERGING";
        revert = "REVERTING";
        bisect = "BISECTING";
        am = "AM";
        am_or_rebase = "AM/REBASE";
        style = "bold yellow";
        disabled = false;
      };

      git_status = {
        # \$ keeps Nix from interpolating starship's own ${...} variables.
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        conflicted = "!=";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        format = "([$all_status$ahead_behind]($style) )";
        # \\( produces a literal backslash-paren, which starship needs to
        # escape the bracket in its own format language.
        staged = "[++\\($count\\)](green)";
        style = "bold purple";
      };

      helm.format = "via [⎈ $version](bold white) ";

      java = {
        symbol = "☕";
        style = "red";
      };

      kubernetes = {
        format = "on [☸ $context \\($namespace\\)](cyan bold) ";
        disabled = true;
        context_aliases."dev.local.cluster.k8s" = "dev";
      };

      python.pyenv_version_name = true;

      shlvl = {
        disabled = false;
        symbol = "↕️";
      };

      username = {
        style_root = "bright-red";
        style_user = "yellow";
        # Carried over as-is, but worth a look: this format has no $user
        # in it, so the module renders only the style wrapper. You
        # probably want "[$user]($style) ".
        format = "($style)";
        show_always = true;
        disabled = false;
      };

      # Not in the original, but now that you are on NixOS the nix_shell
      # module earns its place in the format string above.
      nix_shell = {
        disabled = false;
        symbol = " ";
        format = "via [$symbol$state]($style) ";
        style = "bold blue";
      };
    };
  };
}
