{ pkgs, ... }:
let
  # Was toggle_touchpad.sh, reached through an alias pointing at
  # ~/.dotfiles. Building it as a package means it lands on PATH properly,
  # gets shellcheck run over it at build time, and does not break if you
  # move the repo.
  tptog = pkgs.writeShellApplication {
    name = "tptog";
    runtimeInputs = [ pkgs.glib ];
    text = ''
      current_value=$(gsettings get org.gnome.desktop.peripherals.touchpad send-events)

      if [ "$current_value" = "'enabled'" ]; then
        gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled
        echo "Touchpad disabled."
      else
        gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
        echo "Touchpad enabled."
      fi
    '';
  };

in
{
  home.packages = [ tptog ];
}
