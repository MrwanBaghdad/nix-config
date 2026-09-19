{ ... }:
{
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  home.file.".gitconfig" = {
    text = ''
      [core]
      	editor = vim
        pager = delta
      [url "ssh://git@github.com/"]
      	insteadOf = https://github.com/
      [url "git@github.com:"]
      	insteadOf = https://github.com/
      [init]
      	defaultBranch = main
      [push]
      	autoSetupRemote = true

      [interactive]
          diffFilter = delta --color-only

       [delta]
           navigate = true    # use n and N to move between files
           side-by-side = true # optional side-by-side diff
    '';
  };

  # https://nixos.asia/en/git
  programs = {
    git = {
      enable = true;
      ignores = [ "*~" "*.swp" ];
      signing.format = "openpgp";
      settings = {
        user.name = "MrwanBaghdad";
        alias = {
          ci = "commit";
        };
        # init.defaultBranch = "master";
        # pull.rebase = "false";
      };
    };
    lazygit.enable = true;
  };

}
