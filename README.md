# dotfiles (NixOS)

NixOS equivalent of the `ubuntu` branch, for a **Framework Laptop 13,
12th Gen Intel**. Dotbot, `setup_ubuntu.zsh`, `setup_zsh.zsh` and
`install-scripts/` are all replaced by a flake plus Home Manager, so
there is no install script to run and nothing that mutates the system
outside the config.

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
   sudo nixos-rebuild switch --flake ~/.dotfiles#nixos-laptop
   ```

**`git add` is not optional.** Flakes only see files that git tracks, so
an untracked `hardware-configuration.nix` produces a confusing "path does
not exist" error even though the file is sitting right there. Staging is
enough; you do not have to commit before building. (`--flake
path:$HOME/.dotfiles#nixos-laptop` bypasses git entirely if you ever need it.)

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
modules/nixos/             system: boot, desktop, sway, power, hardware, fonts
modules/home/              user: sway, shell, git, editors, terminal, dconf
pkgs/                      local derivations (vendored fonts)
config/                    files kept verbatim and referenced from Nix
fonts/                     LigaSrcPro + SauceCodePro Nerd Font TTFs
```

Adding a second machine means a new directory under `hosts/` and a new
entry in `flake.nix`; the modules are already shared.

## What moved where

| Ubuntu                                 | NixOS                                                         |
| -------------------------------------- | ------------------------------------------------------------- |
| `install` + dotbot symlinks            | Home Manager                                                  |
| `install.conf.yaml` link/create blocks | `modules/home/default.nix`                                    |
| `setup_zsh.zsh` (chsh, /etc/shells)    | `programs.zsh.enable` + `users.users.<n>.shell`               |
| `apt install` list                     | `modules/home/packages.nix`                                   |
| snaps (brave, discord, spotify, vlc)   | same file, ordinary packages                                  |
| `install-scripts/1password.sh`         | `programs._1password-gui`                                     |
| `install-scripts/starship.sh`          | `programs.starship`                                           |
| `install-scripts/nvm.sh`               | see the note in `packages.nix`                                |
| `ubuntu-drivers autoinstall`           | not needed (Iris Xe); `gpu-nvidia.nix` kept for a future host |
| tlp enable + mask ppd                  | `modules/nixos/power.nix`, two options                        |
| `powertop --calibrate`                 | `powerManagement.powertop.enable`                             |
| `gsettings set ...` lines              | `modules/home/gnome.nix` (dconf)                              |
| guake `--restore-preferences`          | `modules/home/kitty.nix` + sway scratchpad                    |
| vim-plug + `:PlugInstall`              | `programs.neovim.plugins`                                     |
| coc `extensions/package.json`          | `coc-*` plugins from nixpkgs                                  |
| timeshift                              | boot generations, see `backups.nix`                           |
| `zsh/plugins/` submodule               | `programs.zsh.historySubstringSearch`                         |
| `fonts/` (both folders)                | `pkgs/local-fonts.nix`                                        |
| (new) Zed                              | `modules/home/zed.nix`                                        |
| (new) Helix                            | `modules/home/helix.nix`                                      |

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

## Desktop: sway

Sway is the default session; GNOME is still installed and selectable at
GDM, so a broken sway config means picking a different session rather
than a trip to a TTY.

A window manager is not a desktop, so the pieces GNOME was quietly
providing are now explicit:

| GNOME                   | Replacement                                  |
| ----------------------- | -------------------------------------------- |
| top bar, dash-to-dock   | `waybar.nix`                                 |
| notifications           | `mako.nix`                                   |
| app launcher / overview | `fuzzel.nix`                                 |
| lock + idle             | `swaylock.nix` (swaylock-effects + swayidle) |
| screenshots             | `grim` + `slurp`, via the `Print` bindings   |
| **polkit agent**        | `polkit_gnome`, a user service in `sway.nix` |
| display arrangements    | `kanshi.nix`                                 |
| GTK theming             | `gtk.nix` (no settings daemon under sway)    |
| guake                   | `kitty.nix` in sway's scratchpad             |

The polkit agent is the one to remember: without it 1Password cannot
authorise at all, and `pkexec` prompts vanish with no error.

### Window management

Snapping is Rectangle's grid, on `Super+Ctrl`. `Super+Ctrl` rather than
bare `Super` so none of sway's own defaults are displaced.

| Keys                       | Action                                    |
| -------------------------- | ----------------------------------------- |
| `Super+Ctrl+←/→/↑/↓`       | halves                                    |
| `Super+Ctrl+U/I/J/K`       | quarters, clockwise from top-left         |
| `Super+Ctrl+D/F/G`         | first / centre / last third               |
| `Super+Ctrl+E/T`           | first / last two-thirds                   |
| `Super+Ctrl+Return`        | maximise to the workspace                 |
| `Super+Ctrl+C`             | centre, keeping the size                  |
| `Super+,` / `Super+.`      | focus previous / next monitor             |
| `Super+Shift+,` / `+.`     | move window to previous / next monitor    |
| `Super+Ctrl+Q`             | lock                                      |
| `Super+Shift+V`            | clipboard history                         |
| `Alt+Space`                | drop-down terminal (left, 40%x67%)        |
| `Print` / `Shift` / `Ctrl` | screenshot region / output / to clipboard |

**Halves and thirds stay tiled.** They resize a tiled window inside the
layout and shuffle it to the requested end, so its neighbours keep the
rest of the row or column. A half-height means nothing in a row, so the
container is turned into a column first — and the horizontal presets turn
it back, or the two would fight each other.

Quarters need a 2x2 tree the script would have to build, and the result
would depend on what was already on the workspace, so those float
instead, along with maximise and centre. `Super+Shift+Space` tiles a
floated window back.

Snapping is a script rather than plain bindings because neither branch is
expressible as one. Geometry is in `ppt`, which
sway measures against the workspace rect; that already excludes waybar's
reserved space, so the percentages need no bar arithmetic. `ppt` is
integer-only, which is why thirds are 33/34/33 rather than exact.

### Known rough edges

- **Fingerprint does not unlock the screen.** `swaylock` only ever submits
  a typed password, so `fprintAuth` is turned off for its PAM service in
  `modules/nixos/sway.nix` — otherwise `pam_fprintd` sits in front of
  `pam_unix` and the lock screen accepts neither (nixpkgs#171136). sudo,
  polkit and GDM are unaffected. `swaylock-fprintd` would fix this but is
  not in nixpkgs; it needs a flake input or a local derivation.
- **XWayland apps blur at `scale 1.5`.** Same trade-off GNOME had with
  `scale-monitor-framebuffer`, just more visible. Affects input-remapper's
  GUI and anything not yet on Wayland.
- **`services.safeeyes` is X11-oriented** and its break overlays may not
  grab correctly under sway.
- **The docked kanshi profile is a stub.** It needs the make/model/serial
  string from `swaymsg -t get_outputs` with the monitor attached.
- **No clipboard history.** `cliphist` only skips entries carrying the
  password-manager MIME hint, and 1Password does not set it, so every
  copied secret would persist in a plaintext history outliving
  1Password's own clipboard timer. GNOME kept no history either, so
  nothing is lost. `services.cliphist.enable = true` in `sway.nix` if you
  want it anyway.

### Verify on the first login

Sway's config is checked at build time, but these three only fail on real
hardware, and two of them are the kind you would rather not find at 2am:

1. `$mod+Ctrl+Q`, then type your password. Confirms `swaylock-effects`
   registers against the `swaylock` PAM service that `fprintAuth = false`
   was applied to. If it accepts nothing, switch VTs with `Ctrl+Alt+F2`.
2. `systemctl --user status polkit-gnome-authentication-agent-1` should be
   `active (running)`, then check 1Password unlocks with a fingerprint.
   This is also the first thing to check if `pkexec` ever goes quiet.
3. `swaymsg -t get_outputs` to confirm the internal panel really is
   `eDP-1`, and `tptog` to confirm the touchpad toggle lands.

## Framework 13 notes

- `services.fprintd.enable` is on; run `fprintd-enroll azizi` once after
  the first boot to register a finger. Do not prefix it with `sudo` — that
  enrols root instead, and every later check fails with no useful error.
  This covers sudo and polkit (so 1Password unlocks with a fingerprint)
  as well as the login screen.
- Charge limit is set in the BIOS or through sysfs, not TLP. The battery
  is `BAT1` on this machine, which is why the usual `*_BAT0` keys in
  `power.nix` are commented out and pointed here instead.
- The panel is 2256x1504 at ~201 DPI. Under sway that is the `scale`
  line on output `eDP-1` in `sway.nix`, currently 1.5; under the GNOME
  fallback it is still Settings > Displays, unlocked by `gnome.nix`. The
  `window.zoomLevel = 1.5` carried over from your VSCode settings is
  almost certainly too much on top of either. Worth retuning together.
- BIOS updates come through `fwupdmgr`. Have a live USB ready first.

### Hibernation

Closing the lid on battery does `suspend-then-hibernate`: suspend first,
then write the image and power off after `HibernateDelaySec` (25m), or
sooner if the battery would not last that long. Plugged in, the lid still
just locks.

This needs swap, and `power.nix` asserts on it rather than letting it
fail at runtime — logind fails a lid-close outright when it cannot
hibernate rather than degrading to a plain suspend
([systemd#10558](https://github.com/systemd/systemd/issues/10558)), and
the failure mode is a laptop left awake in a bag. So the build stops with
a message instead. To satisfy it:

1. Swap at least the size of RAM, in
   `hosts/laptop/hardware-configuration.nix`. A partition is simplest.
   For a swapfile you also need `boot.kernelParams = [ "resume_offset=N" ]`
   with `N` from `filefrag -v /swapfile`, which can only be read on the
   real machine.
2. `boot.resumeDevice` pointing at the swap partition, or at the
   filesystem holding the swapfile.

If you would rather not set swap up, put `HandleLidSwitch = "suspend"`
back in `power.nix` and the assertion goes away with it.

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
in `neovim.nix`, the VSCode extension list, the GNOME extension UUIDs
in `gnome.nix`, the `framework-tool` attribute name, and the Zed Noctis
extension id in `zed.nix`.

The sway modules were written against verified nixpkgs and Home Manager
`release-26.05` sources, but they have not been built either. Home
Manager's sway module validates the generated config at build time with
`sway --validate`, so syntax errors surface during the rebuild rather
than at login. If that check ever fails for a reason you disagree with,
`wayland.windowManager.sway.checkConfig = false` turns it off.

Helix's `noctis` theme is built in, so that one is safe.
