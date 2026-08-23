{ pkgs, user, ... }:
{
  # This replaces setup_zsh.zsh in full. Enabling zsh here adds it to
  # /etc/shells and installs the system completion files, so there is no
  # chsh step and no editing of /etc/shells.
  programs.zsh.enable = true;

  users.users.${user.name} = {
    isNormalUser = true;
    description = user.fullName;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel" # sudo
      "networkmanager"
      "video"
      "audio"
      "input" # input-remapper
      # "docker"
    ];
  };

  # Passwords stay imperative: set with `passwd` after the first boot, or
  # use hashedPasswordFile if you want them declared. Never put a plain
  # password in a file you push to GitHub.
  users.mutableUsers = true;

  security.sudo.enable = true;
}
