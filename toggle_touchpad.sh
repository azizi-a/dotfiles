#!/usr/bin/env zsh

# Get the current value of the send-events setting
current_value=$(gsettings get org.gnome.desktop.peripherals.touchpad send-events)

# Toggle the value
if [[ "$current_value" == "'enabled'" ]]; then
    gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled
    echo "Touchpad disabled."
else
    gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
    echo "Touchpad enabled."
fi
