{ ... }:
{
  # Replaces GNOME's remembered display arrangements: the first profile
  # whose output set matches wins, so docking restores a layout by itself.
  # Scale stays in sway.nix so there is one source of truth for it.
  services.kanshi = {
    enable = true;

    # Ordered, so more specific profiles come first. `profiles` as an
    # attrset is the old shape and warns on activation.
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
