# dotfiles

Each system has its own branch. `main` holds only these instructions and shares
no history with them.

| Branch        | System              |
| ------------- | ------------------- |
| `arm-macos`   | Apple Silicon macOS |
| `intel-macos` | Intel macOS         |
| `nixos`       | NixOS               |
| `ubuntu`      | Ubuntu              |

## Setup

1. Clone to `~/.dotfiles`

   ```sh
   git clone git@github.com:azizi-a/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
   ```

2. Switch to the branch for this system

   ```sh
   git switch arm-macos
   ```

3. Run the installer

   ```sh
   chmod +x install && ./install
   ```

4. Open `nvim` and run `:PlugInstall`

## Working on a branch

- Add a dotfile by moving it into the repo and listing its old path in
  `install.conf.yaml`
- Put secrets and machine-specific paths in `zsh/zshenv.local` — `install`
  creates it and git ignores it
- Record new brew packages with `bbd` (`brew bundle dump --force --describe`)
- Copy a change to another system with `git cherry-pick`
