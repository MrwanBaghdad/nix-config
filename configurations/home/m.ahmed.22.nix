{ flake, pkgs, lib, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];
  home.username = "m.ahmed.22";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/m.ahmed.22";
  home.stateVersion = "22.11";

  programs.git.settings.user.email = "marwan.nabil@deliveryhero.com";

  # Work-laptop specific Pi configuration.
  home.file.".pi/agent/settings.json".source = ./pi-settings-work.json;
  home.file.".pi/agent/models.json".source = ./pi-models-work.json;
}
