# dotfiles (NixOS)

NixOS equivalent of the `ubuntu` branch, for a **Framework Laptop 13,
12th Gen Intel**. Dotbot, `setup_ubuntu.zsh`, `setup_zsh.zsh` and
`install-scripts/` are all replaced by a flake plus Home Manager, so
there is no install script to run and nothing that mutates the system
outside the config.

## Completing the branch

The `nixos` branch currently has `flake.nix`, `README.md`, both font
folders, and five module files sitting at the repo root. Those five are
correct in content but wrong in location: the flake expects them inside
`modules/`, along with about twenty-five more files that make up the rest
of the tree. This zip contains the complete tree.

From the repo root, on the `nixos` branch:

```sh
cd ~/.dotfiles

# These five belong inside modules/, where the zip has identical copies.
git rm default.nix aliases.nix zsh.nix helix.nix zed.nix

# Unpack the full tree. -o overwrites README.md and flake.nix without
# asking; flake.nix is identical anyway. fonts/ is not in the zip, so
# your committed fonts are untouched.
unzip -o ~/Downloads/nixos-dotfiles.zip

git add -A          # note: the zip includes a .gitignore, easy to miss
git commit -m "Add full module tree"
git push
```

Afterwards the branch should look like the Layout section below — in
particular `hosts/`, `modules/`, `pkgs/` and `config/` must all exist, or
the first line of `flake.nix`'s imports will fail.

## Fonts

Both vendored folders are built into a package by `pkgs/local-fonts.nix`
and installed system-wide by `modules/nixos/fonts.nix`. The family names,
read from the font files themselves:

| Folder | Family | Used for |
| --- | --- | --- |
| `fonts/LigaSrcPro` | `LigaSrc Pro` | editor buffers (VSCodium, Zed) |
| `fonts/SourceCodeProNerdFonts` | `SauceCodePro Nerd Font` | terminals (guake, VSCodium, Zed, and the fontconfig `monospace` default) |
| same folder, Mono files | `SauceCodePro Nerd Font Mono` | installed, unused |
| same folder, Windows Compatible files | `SauceCodePro NF` | installed, unused |

The 28 "Windows Compatible" files (~25 MB) exist for Windows font-name
limits and do nothing on Linux; delete them from the folder if you want a
lighter repo. One correction to a working assumption: this nerd font
*is* in nixpkgs (`nerd-fonts.sauce-code-pro`), but as the v3 patch, and
your files are v2. Icon codepoints moved between those versions, so the
vendored copy is kept deliberately — it keeps glyphs where your existing
guake config expects them. `fonts.nix` has the details.

## Installing on the Framework

1. Install NixOS from the GNOME ISO and create the `azizi` user.
2. Clone the repo and check out this branch:

   ```sh
   git clone https://github.com/azizi-a/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles && git checkout nixos
   ```

3. Replace the placeholder hardware config with the real one:

   ```sh
   sudo nixos-generate-config --show-hardware-config \
     > ~/.dotfiles/hosts/laptop/hardware-configuration.nix
   ```

4. Check the guesses in `modules/nixos/locale.nix` (`time.timeZone`) and
   `modules/nixos/desktop.nix` (`services.xserver.xkb.layout`).
5. Stage everything, then build:

   ```sh
   cd ~/.dotfiles
   git add -A
   sudo nixos-rebuild switch --flake ~/.dotfiles#laptop
   ```

**`git add` is not optional.** Flakes only see files that git tracks, so
an untracked `hardware-configuration.nix` produces a confusing "path does
not exist" error even though the file is sitting right there. Staging is
enough; you do not have to commit before building. (`--flake
path:$HOME/.dotfiles#laptop` bypasses git entirely if you ever need it.)

No `:PlugInstall` step, no `chsh`, no font install, no PPA setup.

## If the first build fails

Expected, and not a problem: nothing here has been evaluated against real
nixpkgs. Errors name the file and line. Fix, `git add -A`, rebuild. You
are still on the installer's generation until a build succeeds, so there
is nothing to break.

## Day to day

```sh
rebuild          # switch to a new config
rebuild-test     # apply without adding a boot entry
nix-update       # bump flake.lock
generations      # list what you can roll back to
```

`nh os switch ~/.dotfiles` does the same as `rebuild` with a nicer diff of
what changed. Rollback is the boot menu, or
`sudo nixos-rebuild switch --rollback`.

## Layout

```
flake.nix                  inputs, and the laptop system definition
hosts/laptop/              hostname, state version, hardware config
modules/nixos/             system: boot, desktop, power, hardware, fonts
modules/home/              user: shell, git, editors, terminal, dconf
pkgs/                      local derivations (vendored fonts)
config/                    files kept verbatim and referenced from Nix
fonts/                     LigaSrcPro + SauceCodePro Nerd Font TTFs
```

Adding a second machine means a new directory under `hosts/` and a new
entry in `flake.nix`; the modules are already shared.

## What moved where

| Ubuntu | NixOS |
| --- | --- |
| `install` + dotbot symlinks | Home Manager |
| `install.conf.yaml` link/create blocks | `modules/home/default.nix` |
| `setup_zsh.zsh` (chsh, /etc/shells) | `programs.zsh.enable` + `users.users.<n>.shell` |
| `apt install` list | `modules/home/packages.nix` |
| snaps (brave, discord, spotify, vlc) | same file, ordinary packages |
| `install-scripts/1password.sh` | `programs._1password-gui` |
| `install-scripts/starship.sh` | `programs.starship` |
| `install-scripts/nvm.sh` | see the note in `packages.nix` |
| `ubuntu-drivers autoinstall` | not needed (Iris Xe); `gpu-nvidia.nix` kept for a future host |
| tlp enable + mask ppd | `modules/nixos/power.nix`, two options |
| `powertop --calibrate` | `powerManagement.powertop.enable` |
| `gsettings set ...` lines | `modules/home/gnome.nix` (dconf) |
| guake `--restore-preferences` | `modules/home/guake.nix` |
| vim-plug + `:PlugInstall` | `programs.neovim.plugins` |
| coc `extensions/package.json` | `coc-*` plugins from nixpkgs |
| timeshift | boot generations, see `backups.nix` |
| `zsh/plugins/` submodule | `programs.zsh.historySubstringSearch` |
| `fonts/` (both folders) | `pkgs/local-fonts.nix` |
| (new) Zed | `modules/home/zed.nix` |
| (new) Helix | `modules/home/helix.nix` |

## Things that changed rather than moved

- **`batcat` is `bat`.** Debian renamed the binary; nixpkgs did not. The
  alias and the `MANPAGER` string are updated.
- **No `--ozone-platform=wayland` flags.** `NIXOS_OZONE_WL=1` is set once
  in `desktop.nix` and every Electron app picks it up, so the `code` alias
  and the `cursor()` wrapper are both simpler.
- **No `$PATH` exports for codium and cursor.** Home Manager puts every
  declared package on `PATH`.
- **`fuction` was a typo** in both `mkcd` and `exists`, so neither
  function ever existed. Both are spelled `function` now, which means
  `mkcd` will start working.
- **lightline was calling `FugitiveHead` without fugitive installed**, so
  the branch segment was always blank. `vim-fugitive` is now in the plugin
  list.
- **`[username].format` in starship** has no `$user` in it. Carried over
  unchanged, but flagged in `starship.nix`.
- **`..` is a function, not an alias.** It takes an optional sibling
  path (`.. src`) and has a completion for siblings of the parent. An
  alias would shadow the function, so `alias ..='cd ..'` is gone.
- **Passwords stay imperative.** `users.mutableUsers = true`, so set
  yours with `passwd`. Do not put a hash in a public repo.

## Framework 13 notes

- `services.fprintd.enable` is on; run `fprintd-enroll` once after the
  first boot to register a finger.
- Charge limit is set in the BIOS or through sysfs, not TLP. The battery
  is `BAT1` on this machine, which is why the usual `*_BAT0` keys in
  `power.nix` are commented out and pointed here instead.
- The panel is 2256x1504 at ~201 DPI. `gnome.nix` unlocks fractional
  scaling; pick 125% or 150% in Settings > Displays. Once you do, the
  `window.zoomLevel = 1.75` carried over from your VSCodium settings will
  almost certainly be too much. Worth retuning both together.
- BIOS updates come through `fwupdmgr`. Have a live USB ready first.

## Not yet decided

- `nodejs` version management. Three options are laid out in
  `packages.nix`; per-project flakes with direnv is the one that fits
  NixOS best, but it is the biggest change to your workflow.
- Whether to keep Deja Dup or move to declarative restic backups.
  `backups.nix` has a sketch of the latter.
- Secrets. Nothing here needs them yet, but when something does, look at
  sops-nix or agenix rather than putting files in the repo.

## Caveat

None of this has been evaluated against real nixpkgs. Attribute names
drift between releases, so expect two or three "attribute missing" errors
on the first build; `nix flake check` and `nix repl` will name them
precisely. The places most likely to need a nudge are the noctis plugin
in `neovim.nix`, the VSCodium extension list, the GNOME extension UUIDs
in `gnome.nix`, the `framework-tool` attribute name, and the Zed Noctis
extension id in `zed.nix`.

Helix's `noctis` theme is built in, so that one is safe.
