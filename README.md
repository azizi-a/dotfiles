# dotfiles

## TODO

- Terminal Preferences
- Changed Shell to ZSH
- Mission Control Preferences (don't rearrange spaces)
- Dock Preferences
- Finder Show Path Bar
- gitconfig
- Brewfile
- Fonts
- Aliases

# Usage Instructions

1. Clone repo to `~/.dotfiles`
2. Run the `install` binary
3. Open `nvim` and run `:PlugInstall`
4. To add new dotfiles, cut them to this directory and list their old location
   in `instal.conf.yaml`
5. To backup new brew packages in `Brewfile` run `bbd` (alias for
   `brew bundle dump --force --describe`)
