{ ... }:
let
  theme = import ./theme.nix;
in
{
  # Notification daemon. GNOME Shell was the one handling this; without a
  # daemon running, notify-send fails and anything using libnotify goes
  # quiet rather than erroring visibly.
  #
  # Keys are the kebab-case names from mako(5) and go straight into
  # mako.ini. The old camelCase options (defaultTimeout, backgroundColor,
  # ...) still work as deprecated aliases but warn on activation.
  services.mako = {
    enable = true;

    settings = {
      font = "${theme.font} 11";
      background-color = "#${theme.bg}";
      text-color = "#${theme.fg}";
      border-color = "#${theme.accent}";
      border-size = 2;
      border-radius = 4;
      padding = "10";
      margin = "10";
      default-timeout = 5000;
      max-visible = 5;
      anchor = "top-right";

      # Nested attrsets are criteria sections. Anything marked urgent
      # should not disappear on its own.
      "urgency=critical" = {
        border-color = "#${theme.urgent}";
        default-timeout = 0;
      };
    };
  };
}
