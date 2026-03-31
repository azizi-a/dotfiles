# dotfiles

# Usage Instructions

1. Clone repo to `~/.dotfiles` - `git clone https://github.com/azizi-a/dotfiles.git ~/.dotfiles`
2. Checkout branch that matches OS, `arm-macos`, `intell-macos`, or `ubuntu`
3. Run the `install` binary
4. To add new dotfiles, cut them to this directory and list their old location
   in `instal.conf.yaml`
5. To backup new brew packages in `Brewfile` run `bbd` (alias for
   `brew bundle dump --force --describe`)
