{ pkgs, ... }:
let
  # Was toggle_touchpad.sh, reached through an alias pointing at
  # ~/.dotfiles. Building it as a package means it lands on PATH properly,
  # gets shellcheck run over it at build time, and does not break if you
  # move the repo.
  #
  # Drives sway rather than gsettings: the GNOME key it used to set is
  # read by mutter, so under sway it toggled a value nothing acts on.
  tptog = pkgs.writeShellApplication {
    name = "tptog";
    runtimeInputs = with pkgs; [
      sway
      jq
    ];
    text = ''
      swaymsg input type:touchpad events toggle enabled disabled >/dev/null

      state=$(swaymsg -t get_inputs \
        | jq -r 'first(.[] | select(.type == "touchpad") | .libinput.send_events)')

      case "$state" in
        enabled)  echo "Touchpad enabled." ;;
        disabled) echo "Touchpad disabled." ;;
        *)        echo "Touchpad state: ''${state:-unknown}" ;;
      esac
    '';
  };
in
{
  home.packages = [ tptog ];
}
