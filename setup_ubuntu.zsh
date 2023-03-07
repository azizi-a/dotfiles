#!/usr/bin/env zsh

echo "\n<<< Starting Ubuntu Setup >>>\n"

# Installs
# install drivers
sudo ubuntu-drivers autoinstall

# install from scripts
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
  echo "Already installed: nvm"
else
  install-script nvm
fi
install-script 1password
install-script starship

# apt installs
sudo apt update

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    sudo apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

install bat
install chromium-browser
install curl
install direnv
install exa
install firefox
install fonts-firacode
install git
install httpie
install less
install nano
install neovim
install vim
install zsh
install zsh-autosuggestions
install zsh-syntax-highlighting

sudo apt autoremove -y

# install snaps
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
install-snap spotify
install-snap vlc

if [ which code &> /dev/nul -ne 0 ]; then
  echo "Installing: code..."
  sudo snap install --classic code
else
  echo "Already installed: code"
fi

# Power Managment
if [ which tlp &> /dev/null -ne 0 ]; then
  install tlp

  echo "Enabling tlp"
  sudo systemctl enable tlp.service
  sudo systemctl start tlp.service
  
  echo "Disabling and masinging power-profiles-daemon"
  sudo systemctl stop power-profiles-daemon.service
  sudo systemctl disable power-profiles-daemon.service
  sudo systemctl mask power-profiles-daemon.service
else
  echo "tlp already installed and enabled"
fi

if [ which powertop &> /dev/null -ne 0 ]; then
  install powertop
  
  echo "<< Calibrating powertop >>"
  sudo powertop --calibrate
  echo "<< powertop calibrated >>"
else
  echo "powertop already installed and calibrated"
fi

# GNOME setup
install gnome-tweaks
install chrome-gnome-shell

# Finish Ubuntu Setup

echo "\n<<< Ubuntu Setup Complete >>>\n"