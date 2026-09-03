{ pkgs, user, ... }:
{
  # Adds zsh to /etc/shells and installs system completions, so no chsh.
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

  # Imperative: `passwd` after first boot, or hashedPasswordFile.
  users.mutableUsers = true;

  security.sudo.enable = true;
}
