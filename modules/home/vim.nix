{ ... }:
{
  # The separate, minimal vim you kept alongside nvim.
  programs.vim = {
    enable = true;

    extraConfig = ''
      set number
      set relativenumber
      set tabstop=4
      set shiftwidth=4
      set autoindent
      set mouse=a
      set wildmenu

      inoremap jj <Esc>
      inoremap kk <Esc>
    '';
  };
}
