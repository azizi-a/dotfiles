{ pkgs, ... }:
let
  # A package so it lands on PATH and gets shellchecked at build time.
  # Drives swaymsg: the GNOME key it used to set is read by mutter.
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
