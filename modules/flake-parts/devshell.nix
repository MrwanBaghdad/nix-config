{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-unified-template-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      packages = with pkgs; [
        just
        nixd
      ];
    };
    devShells.golang = pkgs.mkShell {
      name = "golang-experimental-shell";
      meta.description = "Shell for golang development";
      packages = with pkgs; [
        golangci-lint
        gosec
      ];
    };
  };
}
