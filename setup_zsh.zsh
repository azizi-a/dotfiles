#!/usr/bin/env zsh

echo "\n<<< Starting ZSH Setup >>>\n"

# Intilation unnecerssary; it's in the Brewfile.

if grep -Fxq '/opt/homebrew/bin/zsh' '/etc/shells'; then
  echo '"/opt/homebrew/bin/zsh" already exits in /etc/shells'
else
  echo "Enter superuser (sudo) password to edit /etc/shells"
  echo '/opt/homebrew/bin/zsh' | sudo tee -a '/etc/shells' >/dev/null
fi

if [ "$SHELL" = '/opt/homebrew/bin/zsh' ]; then
  echo '$SHELL is already /opt/homebrew/bin/zsh'
else
  # Change login shell"
  chsh -s '/usr/homebrew/bin/zsh'
fi

if sh --version | grep -q zsh; then
  echo "/private/var/select/sh already linked to /bin/zsh"
else
  echo "Enter superuser (sudo) password to symlink sh to zsh"
  # more consistant but probably not important
  sudo ln -sfv /bin/zsh /private/var/select/sh
fi

echo "\n<<< ZSH Setup Complete >>>\n"
