#!/usr/bin/env zsh

echo "\n<<< Starting Ubuntu Setup >>>"

# Installs
echo "\n< Installing drivers... >"
sudo ubuntu-drivers autoinstall

echo "\n< Installing from scripts... >"
function install-script {
  which $1 &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    ./install-scripts/$1.sh
  else
    echo "Already installed: ${1}"
  fi
}

if [ nvm --version &> /dev/null -ne 0 ]; then
  install-script nvm
else
  echo "Already installed: nvm"
fi
install-script 1password
install-script starship

# apt installs
echo "\n< Updating package list >"
sudo apt update

echo "\n< installing apt packages... >"
function install-apt {
  if dpkg -s $1 >/dev/null 2>&1; then
    echo "already installed: ${1}"
  else
    echo "installing: ${1}..."
    sudo apt-get install -y $1
  fi
}
install-apt bat
install-apt chromium-browser
install-apt codium
install-apt curl
install-apt deja-dup
install-apt direnv
install-apt eza
install-apt fonts-firacode
install-apt fzf
install-apt git
install-apt guake
install-apt httpie
install-apt input-remapper
install-apt less
install-apt nano
install-apt neovim
install-apt safeeyes
install-apt timeshift
install-apt vim
install-apt zsh
install-apt zsh-autosuggestions
install-apt zsh-syntax-highlighting

echo "\n< Cleaning up dependencies >"
sudo apt autoremove -y

# install snaps
echo "\n< Installing Snaps...>"
function install-snap {
  which $1 &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo snap install $1
  else
    echo "Already installed: ${1}"
  fi
}
install-snap brave
install-snap discord
install-snap firefox
install-snap spotify
install-snap vlc

# if [ which code &> /dev/null -ne 0 ]; then
#   echo "Installing: code..."
#   sudo snap install --classic code
# else
#   echo "Already installed: code"
# fi

# Power Managment
echo "\n< Power managment installs >"
if [ which tlp &> /dev/null -ne 0 ]; then
  install-apt tlp

  echo "Enabling tlp"
  sudo systemctl enable tlp.service
  sudo systemctl start tlp.service
  
  echo "Disabling and maskinging power-profiles-daemon"
  sudo systemctl stop power-profiles-daemon.service
  sudo systemctl disable power-profiles-daemon.service
  sudo systemctl mask power-profiles-daemon.service
else
  echo "TLP already installed and enabled"
fi

if [ which powertop &> /dev/null -ne 0 ]; then
  install-apt powertop
  
  echo "\n<< Calibrating Powertop >>"
  sudo powertop --calibrate
  echo "<< Powertop Calibrated >>\n"
else
  echo "Powertop already installed and calibrated"
fi

# GNOME setup
echo "\n< GNOME installs running... >"
install-apt gnome-tweaks
install-apt gnome-shell-extension-manager 

echo "\n< GNOME setup running... >"
# set caps-lock to esc (+shift for caps-lock)
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape_shifted_capslock']"
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-viridian-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-viridian'
gsettings set org.gnome.mutter center-new-windows true 
gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-monitors false
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
echo "< GNOME setup finshed >"
# Remove Super + Up/Down keybindings
gsettings set org.gnome.shell.keybindings shift-overview-up "[]"
gsettings set org.gnome.shell.keybindings shift-overview-down "[]"



echo "\n< Restroing guake terminal settings... >"
# save preferances with `guake --save-preferences='.config/guake/preferences'`
guake --restore-preferences='.config/guake/preferences'
echo "< guake setup finshed >"

# Finish Ubuntu Setup

echo "\n<<< Ubuntu Setup Complete >>>\n"
