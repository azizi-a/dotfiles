#!/usr/bin/env zsh

echo "\n<<< Starting macOS Setup >>>\n"

osascript -e 'tell application "System Preferences" to quit'

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder > Preferences > General > New Finder windows show:
defaults write com.apple.finder NewWindowTarget -string 'PfLo'
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/.dotfiles"

#!/usr/bin/env zsh

# System Preferences > Dock
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock largesize -int 64
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock autohide-delay -float 0.1

# iTerm2 Settings
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.dotfiles/iterm2"
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true

# Remove mouse acceleration
defaults write -g com.apple.mouse.scaling -int -1

# LigaSrcPro is a custom build, so Homebrew can't provide it.
mkdir -p "$HOME/Library/Fonts"
for font in "$HOME"/.dotfiles/fonts/*/*.(ttf|otf)(N); do
  [[ -e "$HOME/Library/Fonts/${font:t}" ]] || cp "$font" "$HOME/Library/Fonts/"
done

# Finish macOS Setup
killall Finder
killall Dock
echo "\n<<< macOS Setup Complete >>>\n"