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
      [url "ssh://git@github.com/"]
      	insteadOf = https://github.com/
      [url "git@github.com:"]
      	insteadOf = https://github.com/
      [init]
      	defaultBranch = main
      [push]
      	autoSetupRemote = true
    '';
  };

  # https://nixos.asia/en/git
  programs = {
    git = {
      enable = true;
      userName = "MrwanBaghdad";
      ignores = [ "*~" "*.swp" ];
      aliases = {
        ci = "commit";
      };
      extraConfig = {
        # init.defaultBranch = "master";
        # pull.rebase = "false";
      };
    };
    lazygit.enable = true;
  };

}
