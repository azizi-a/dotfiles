# dotfiles

# Usage Instructions

1. Clone repo to `~/.dotfiles`
   ```sh
   git clone https://github.com/azizi-a/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
   ```
   
3. Checkout branch that matches OS, `arm-macos`, `intell-macos`, or `ubuntu`
   ```sh
   git switch ${BRANCH_NAME}
   ```
   
4. Make sure the install binary is executable 
   ```sh
   chmod +x install
   ```
   
6. Run the `install` binary
   ```sh
   ./install
   ```
   
7. To add new dotfiles, cut them to this directory and list their old location
   in `instal.conf.yaml`
   
9. To backup new brew packages in `Brewfile` run `bbd` (alias for
   `brew bundle dump --force --describe`)
