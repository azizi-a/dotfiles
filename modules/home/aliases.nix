{ ... }:
{
  home.shellAliases = {
    # --- Navigation -------------------------------------------------------
    "~" = "cd ~";
    # `..` is deliberately NOT an alias any more. It is a function in
    # zsh.nix so it can take an optional sibling path, and an alias would
    # win over the function at parse time.

    # --- Listing ----------------------------------------------------------
    ll = "eza -lah --icons";

    # --- Tools ------------------------------------------------------------
    pn = "pnpm";
    py = "python";
    pgsql = "echo psql: && psql";
    hf = "history -1000 | fzf";

    # Backslash escapes the $ so Nix leaves the zsh expansion alone.
    path = "<<<\${(F)path}";

    # `alias bat=batcat` is dropped: nixpkgs ships the binary as `bat`.

    # No --ozone-platform=wayland here. NIXOS_OZONE_WL=1 is set globally
    # in modules/nixos/desktop.nix, so every Electron app picks Wayland up.
    code = "codium";

    # The cursor() wrapper function is also gone: --no-sandbox was working
    # around the AppImage on Ubuntu, and the nixpkgs build does not need
    # it. `cursor-update` has no meaning now that updates come from a
    # rebuild, so it is dropped too.

    # tptog now points at the script built in scripts.nix rather than a
    # checked-in shell file, so there is no ~/.dotfiles path to keep valid.

    # --- Nix --------------------------------------------------------------
    rebuild = "sudo nixos-rebuild switch --flake ~/.dotfiles#laptop";
    rebuild-test = "sudo nixos-rebuild test --flake ~/.dotfiles#laptop";
    rebuild-boot = "sudo nixos-rebuild boot --flake ~/.dotfiles#laptop";
    nix-update = "nix flake update --flake ~/.dotfiles";
    nix-clean = "sudo nix-collect-garbage --delete-older-than 30d";
    generations = "nixos-rebuild list-generations";
  };
}
