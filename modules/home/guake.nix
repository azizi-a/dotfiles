{ pkgs, ... }:
{
  home.packages = [ pkgs.guake ];

  # Your saved preferences, unchanged. Guake stores its real settings in
  # dconf; this file is the export format that `guake --save-preferences`
  # writes and `--restore-preferences` reads.
  xdg.configFile."guake/preferences".source = ../../config/guake/preferences;

  # Start with the session. On Ubuntu this came from the start-at-login
  # setting inside the preferences file, which made guake write its own
  # autostart entry at runtime. Declaring it here means it works on a
  # fresh machine before guake has ever been launched.
  xdg.configFile."autostart/guake.desktop".source =
    "${pkgs.guake}/share/applications/guake.desktop";

  # Apply the preferences on activation, but only once, so it does not
  # stamp on changes you make later through the preferences dialog.
  # Delete the stamp file to force a re-apply:
  #   rm ~/.local/state/guake-prefs-restored
  home.activation.guakePreferences = ''
    stamp="$HOME/.local/state/guake-prefs-restored"
    if [ ! -e "$stamp" ] && [ -n "''${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
      run mkdir -p "$HOME/.local/state"
      run ${pkgs.guake}/bin/guake \
        --restore-preferences="$HOME/.config/guake/preferences" || true
      run touch "$stamp"
    fi
  '';

  # --- Fully declarative alternative --------------------------------------
  # If you would rather have the settings in Nix, they map onto dconf
  # paths one to one: the [general] section of the preferences file is
  # /apps/guake/general, [style/font] is /apps/guake/style/font, and so
  # on. Roughly:
  #
  # dconf.settings = {
  #   "apps/guake/general" = {
  #     window-height = 50;
  #     window-width = 67;
  #     use-scrollbar = false;
  #     start-at-login = true;
  #   };
  #   "apps/guake/keybindings/global".show-hide = "<Alt>space";
  #   "apps/guake/style/background".transparency = 90;
  #   "apps/guake/style/font".style = "SauceCodePro Nerd Font 13";
  # };
  #
  # The catch is that dconf is strict about GVariant types, and guake's
  # schema uses a mix of int and uint for the numeric keys. Get one wrong
  # and activation fails. The restore approach above sidesteps that, and
  # keeps your existing `guake --save-preferences` workflow intact.
}
