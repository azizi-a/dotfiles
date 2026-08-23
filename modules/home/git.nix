{ user, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = user.fullName;
        email = user.email;
      };

      core = {
        editor = "zed --wait";
        autocrlf = "input";
        ignoreCase = false;
      };

      init.defaultBranch = "main";

      # Additions, not carried over from the Ubuntu gitconfig. Remove any
      # you disagree with.
      pull.rebase = true; # matches your gup/gupa aliases
      push.autoSetupRemote = true; # makes gpsup mostly unnecessary
      diff.colorMoved = "default";
      rerere.enabled = true; # remembers conflict resolutions
      fetch.prune = true;
    };

    # gbda in your git-aliases only catches genuinely merged branches.
    # If you want the squash-merge-aware version too, drop it in here as
    # an alias rather than another shell function.
    settings.alias = {
      staash = "stash --all";
    };
  };

  # The other half of what `git config --global core.excludesfile` would do.
  home.file.".config/git/ignore".text = ''
    .DS_Store
    result
    result-*
    .direnv/
  '';
}
