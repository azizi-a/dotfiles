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

echo "\n< Installing apt packages... >"
function install-apt {
  if dpkg -s $1 >/dev/null 2>&1; then
    echo "Already installed: ${1}"
  else
    echo "Installing: ${1}..."
    sudo apt-get install -y $1
  fi
}
install-apt bat
install-apt chromium-browser
install-apt curl
install-apt direnv
install-apt exa
install-apt fonts-firacode
install-apt git
install-apt httpie
install-apt less
install-apt nano
install-apt neovim
install-apt safeeyes
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
install-snap firefox
install-snap spotify
install-snap vlc

if [ which code &> /dev/null -ne 0 ]; then
  echo "Installing: code..."
  sudo snap install --classic code
else
  echo "Already installed: code"
fi

# Power Managment
echo "\n< Power managment installs >"
if [ which tlp &> /dev/null -ne 0 ]; then
  install-apt tlp

  echo "Enabling tlp"
  sudo systemctl enable tlp.service
  sudo systemctl start tlp.service
  
  echo "Disabling and masinging power-profiles-daemon"
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
echo "\n< GNOME installs running.. >"
install-apt gnome-tweaks
install-apt chrome-gnome-shell

echo "\n< GNOME setup running.. >"
# set caps-lock to ctrl
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
echo "< GNOME setup finshed >"

# Finish Ubuntu Setup

echo "\n<<< Ubuntu Setup Complete >>>\n"