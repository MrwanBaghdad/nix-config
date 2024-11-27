# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "RPFL2456TK";

  # For home-manager to work.
  # https://github.com/nix-community/home-manager/issues/4026#issuecomment-1565487545
  users.users."m.ahmed.22".home = "/Users/m.ahmed.22";

  # Enable home-manager for "marwan" user
  home-manager.users."m.ahmed.22" = {
    imports = [ (self + /configurations/home/m.ahmed.22.nix) ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
