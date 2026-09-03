{ ... }:
{
  # First profile whose output set matches wins. Scale lives in sway.nix.
  services.kanshi = {
    enable = true;

    # Ordered: more specific profiles first.
    settings = [
      {
        profile.name = "laptop";
        profile.outputs = [ { criteria = "eDP-1"; } ];
      }

      # Fill in from `swaymsg -t get_outputs`. A "make model serial"
      # criteria follows the monitor between ports; a connector name does not.
      #
      # {
      #   profile.name = "docked";
      #   profile.outputs = [
      #     {
      #       criteria = "Dell Inc. DELL U2722DE ABCD123";
      #       position = "0,0";
      #       mode = "2560x1440@59.951Hz";
      #     }
      #     {
      #       criteria = "eDP-1";
      #       position = "0,1440";
      #     }
      #   ];
      # }
    ];
  };
}
