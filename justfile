# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

# Default command when 'just' is run without arguments
default:
  @just --list

# Update nix flake
[group('Main')]
update:
  nix flake update

# Lint nix files
[group('dev')]
lint:
  nix fmt

# Check nix flake
[group('dev')]
check:
  nix flake check

# Manually enter dev shell
[group('dev')]
dev:
  nix develop

# Activate the configuration
[group('Main')]
run:
  nix run

# Add a nixpkgs package to modules/home/packages.nix
[group('config')]
add-pkg package:
  python3 scripts/nixcfg.py add pkg "{{package}}"
  nix fmt

# Remove a nixpkgs package from modules/home/packages.nix
[group('config')]
rm-pkg package:
  python3 scripts/nixcfg.py rm pkg "{{package}}"
  nix fmt

# Add a Homebrew formula to modules/darwin/apps.nix
[group('config')]
add-brew formula:
  python3 scripts/nixcfg.py add brew "{{formula}}"
  nix fmt

# Remove a Homebrew formula from modules/darwin/apps.nix
[group('config')]
rm-brew formula:
  python3 scripts/nixcfg.py rm brew "{{formula}}"
  nix fmt

# Add a Homebrew cask to modules/darwin/apps.nix
[group('config')]
add-cask cask:
  python3 scripts/nixcfg.py add cask "{{cask}}"
  nix fmt

# Remove a Homebrew cask from modules/darwin/apps.nix
[group('config')]
rm-cask cask:
  python3 scripts/nixcfg.py rm cask "{{cask}}"
  nix fmt

# Add a Homebrew tap to modules/darwin/apps.nix
[group('config')]
add-tap tap:
  python3 scripts/nixcfg.py add tap "{{tap}}"
  nix fmt

# Remove a Homebrew tap from modules/darwin/apps.nix
[group('config')]
rm-tap tap:
  python3 scripts/nixcfg.py rm tap "{{tap}}"
  nix fmt

# Enable/disable Homebrew upgrades during nix-darwin activation
[group('config')]
brew-upgrade enabled:
  python3 scripts/nixcfg.py set-brew-upgrade "{{enabled}}"
  nix fmt

# Open the main package/app config files in $EDITOR
[group('config')]
config-edit:
  ${EDITOR:-vim} modules/home/packages.nix modules/darwin/apps.nix
