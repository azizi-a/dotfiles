#!/usr/bin/env zsh

# Currently, you can't do `brew bundle --no-quarantine` as an option,
# therfore it's an exported variable in `zshenv` making it available to
# Homebrew for the first install (before our `zshrc` is sourced):
# export HOMEBREW_CASK_OPTS="--no-quarantine"
# https://github.com/Homebrew/homebrew-bundle/issues/474
# https://github.com/Homebrew/homebrew-bundle/issues/940

echo "\n<<< Starting Homebrew Setup >>>\n"

if exists brew; then
 echo "brew exists. Skipping brew install."
else
  echo "brew doesn't exist. Installing brew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle --verbose