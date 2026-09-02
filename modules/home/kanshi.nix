{ ... }:
{
  # Replaces GNOME's remembered display arrangements. kanshi watches for
  # outputs appearing and disappearing and applies the first profile whose
  # output set matches, so docking and undocking restore a layout without
  # editing this file or re-dragging monitors.
  #
  # Scale stays in modules/home/sway.nix rather than being repeated here,
  # so there is one source of truth for it and the panel is still legible
  # if kanshi ever fails to start. This file only owns arrangement.
  services.kanshi = {
    enable = true;

    # An ordered list: the first matching profile wins, so more specific
    # profiles must come first. `profiles` as an attrset is the old shape
    # and now warns on activation.
    settings = [
      {
        profile.name = "laptop";
        profile.outputs = [ { criteria = "eDP-1"; } ];
      }

      # Fill in from `swaymsg -t get_outputs` once an external monitor is
      # plugged in: criteria takes either a connector name (DP-3) or a
      # "make model serial" string, which is the one worth using because
      # it follows the monitor between ports. Positions are in layout
      # pixels with the origin top-left, so the line below puts the
      # laptop panel underneath a 2560x1440 external.
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
