#!/usr/bin/env zsh

echo "\n<<< Starting ZSH Setup >>>\n"

if which zsh &> /dev/null; then
  echo 'zsh already installed'
else
  echo "Enter superuser (sudo) password to install zsh"
  sudo apt install zsh
fi

if grep -Fxq '/usr/bin/zsh' '/etc/shells'; then
  echo '"/usr/bin/zsh" already exits in /etc/shells'
else
  echo "Enter superuser (sudo) password to edit /etc/shells"
  echo '/usr/bin/zsh' | sudo tee -a '/etc/shells' >/dev/null
fi

if [ "$SHELL" = '/usr/bin/zsh' ]; then
  echo '$SHELL is already /usr/bin/zsh'
else
  # Change login shell"
  chsh -s '/usr/bin/zsh'
fi

echo "\n<<< ZSH Setup Complete >>>\n"
