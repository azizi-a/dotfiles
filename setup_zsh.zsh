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


echo "\n<<< ZSH Setup Complete >>>\n"
