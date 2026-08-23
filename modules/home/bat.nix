{ pkgs, ... }:
{
  programs.bat = {
    enable = true;

    config = {
      theme = "Dracula";

      # Same two mappings as the Ubuntu config file. The option takes a
      # list here rather than repeated --map-syntax lines.
      map-syntax = [
        "zshrc:Bourne Again Shell (bash)"
        "zshenv:Bourne Again Shell (bash)"
        "*.nix:Nix"
      ];
    };

    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman # `batman <cmd>` for man pages, alongside your MANPAGER
      batgrep
    ];
  };
}
