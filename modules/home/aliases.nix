{ ... }:
{
  home.shellAliases = {
    # --- Navigation -------------------------------------------------------
    "~" = "cd ~";
    # `..` is a function in zsh.nix; an alias would shadow it.

    # --- Listing ----------------------------------------------------------
    ll = "eza -lah --icons";

    # --- Tools ------------------------------------------------------------
    pn = "pnpm";
    py = "python";
    pgsql = "echo psql: && psql";
    hf = "history -1000 | fzf";

    # Backslash escapes the $ so Nix leaves the zsh expansion alone.
    path = "<<<\${(F)path}";

    # No ozone flag needed: NIXOS_OZONE_WL is set in desktop.nix.
    code = "codium";

    # --- Nix --------------------------------------------------------------
    rebuild = "sudo nixos-rebuild switch --flake ~/.dotfiles#nixos-laptop";
    rebuild-test = "sudo nixos-rebuild test --flake ~/.dotfiles#nixos-laptop";
    rebuild-boot = "sudo nixos-rebuild boot --flake ~/.dotfiles#nixos-laptop";
    nix-update = "nix flake update --flake ~/.dotfiles";
    nix-clean = "sudo nix-collect-garbage --delete-older-than 30d";
    generations = "nixos-rebuild list-generations";
  };
}
