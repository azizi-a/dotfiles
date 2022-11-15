#!/usr/bin/env zsh

echo "\n<<< Starting ZSH Setup >>>\n"

# Intilation unnecerssary; it's in the Brewfile.

if grep -Fxq '/usr/local/bin/zsh' '/etc/shells'; then
  echo '"/usr/local/bin/zsh" already exits in /etc/shells'
else
  echo "Enter superuser (sudo) password to edit /etc/shells"
  echo '/usr/local/bin/zsh' | sudo tee -a '/etc/shells' >/dev/null
fi

if [ "$SHELL" = '/usr/local/bin/zsh' ]; then
  echo '$SHELL is already /usr/local/bin/zsh'
else
  # Change login shell"
  chsh -s '/usr/local/bin/zsh'
fi

if sh --version | grep -q zsh; then
  echo "/private/var/select/sh already linked to /bin/zsh"
else
  echo "Enter superuser (sudo) password to symlink sh to zsh"
  # more consistant but probably not important
  sudo ln -sfv /bin/zsh /private/var/select/sh
fi

echo "\n<<< ZSH Setup Complete >>>\n"
