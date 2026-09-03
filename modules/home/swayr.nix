{ pkgs, ... }:
{
  # The daemon is what tracks the most-recently-used order.
  programs.swayr = {
    enable = true;
    systemd.enable = true;

    settings = {
      menu = {
        executable = "${pkgs.fuzzel}/bin/fuzzel";
        args = [
          "--dmenu"
          "--prompt={prompt} "
        ];
      };

      # The shipped formats are wofi's; fuzzel renders none of that markup.
      format = {
        window_format = "{workspace_name}  {app_name}  {title}";
        urgency_start = "! ";
        urgency_end = "";
        html_escape = false;
      };
    };
  };
}
