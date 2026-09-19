#!/usr/bin/env python3
"""Small CLI helpers for editing this repo's declarative Nix config."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APPS = ROOT / "modules" / "darwin" / "apps.nix"
PACKAGES = ROOT / "modules" / "home" / "packages.nix"

TARGETS = {
    "home-pkg": (PACKAGES, "home.packages", "bare"),
    "pkg": (PACKAGES, "home.packages", "bare"),
    "brew": (APPS, "brews", "string"),
    "cask": (APPS, "casks", "string"),
    "tap": (APPS, "taps", "string"),
}


def usage(exit_code: int = 2) -> None:
    print(
        """Usage:
  scripts/nixcfg.py add <home-pkg|pkg|brew|cask|tap> <name>
  scripts/nixcfg.py rm  <home-pkg|pkg|brew|cask|tap> <name>
  scripts/nixcfg.py set-brew-upgrade <true|false>

Examples:
  scripts/nixcfg.py add pkg jq
  scripts/nixcfg.py add brew pkgconf
  scripts/nixcfg.py add cask firefox
  scripts/nixcfg.py rm cask visual-studio-code
  scripts/nixcfg.py set-brew-upgrade false
""".rstrip(),
        file=sys.stderr,
    )
    raise SystemExit(exit_code)


def validate_name(name: str, kind: str) -> None:
    if not name or any(ch in name for ch in "\n\r\t;[]{}"):
        raise SystemExit(f"Invalid {kind} name: {name!r}")
    if kind == "bare" and not re.fullmatch(r"[A-Za-z0-9_+.'-]+", name):
        raise SystemExit(
            f"Invalid Nix package attr {name!r}; use a simple nixpkgs attribute name."
        )
    if kind == "string" and '"' in name:
        raise SystemExit(f"Invalid string item {name!r}: double quotes are not supported")


def find_list(lines: list[str], attr: str) -> tuple[int, int, str]:
    start_re = re.compile(
        rf"^(?P<indent>\s*){re.escape(attr)}\s*=\s*(?:with\s+pkgs;\s*)?\[\s*$"
    )
    for i, line in enumerate(lines):
        match = start_re.match(line)
        if not match:
            continue
        start_indent = match.group("indent")
        # These config lists are simple one-level lists. Stop at the first ];.
        for j in range(i + 1, len(lines)):
            if re.match(rf"^{re.escape(start_indent)}\s*\];\s*$", lines[j]):
                return i, j, start_indent + "  "
        raise SystemExit(f"Found {attr} in {lines!r}, but could not find closing ];")
    raise SystemExit(f"Could not find list assignment for {attr}")


def item_line(name: str, kind: str, indent: str) -> str:
    if kind == "string":
        return f'{indent}"{name}"\n'
    return f"{indent}{name}\n"


def line_matches_item(line: str, name: str, kind: str) -> bool:
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return False
    if kind == "string":
        return re.match(rf'^"{re.escape(name)}"(?:\s|#|$)', stripped) is not None
    return re.match(rf'^{re.escape(name)}(?:\s|#|$)', stripped) is not None


def add_item(target: str, name: str) -> None:
    try:
        path, attr, kind = TARGETS[target]
    except KeyError:
        raise SystemExit(f"Unknown target {target!r}")
    validate_name(name, kind)

    lines = path.read_text().splitlines(keepends=True)
    start, end, indent = find_list(lines, attr)
    if any(line_matches_item(line, name, kind) for line in lines[start + 1 : end]):
        print(f"Already present: {name} in {path.relative_to(ROOT)}:{attr}")
        return

    lines.insert(end, item_line(name, kind, indent))
    path.write_text("".join(lines))
    print(f"Added {name} to {path.relative_to(ROOT)}:{attr}")


def rm_item(target: str, name: str) -> None:
    try:
        path, attr, kind = TARGETS[target]
    except KeyError:
        raise SystemExit(f"Unknown target {target!r}")
    validate_name(name, kind)

    lines = path.read_text().splitlines(keepends=True)
    start, end, _indent = find_list(lines, attr)
    remove_indexes = [
        i for i in range(start + 1, end) if line_matches_item(lines[i], name, kind)
    ]
    if not remove_indexes:
        print(f"Not present: {name} in {path.relative_to(ROOT)}:{attr}")
        return

    for i in reversed(remove_indexes):
        del lines[i]
    path.write_text("".join(lines))
    print(f"Removed {name} from {path.relative_to(ROOT)}:{attr}")


def set_brew_upgrade(value: str) -> None:
    if value not in {"true", "false"}:
        raise SystemExit("set-brew-upgrade value must be true or false")
    text = APPS.read_text()
    new, count = re.subn(
        r"(\n\s*upgrade\s*=\s*)(true|false)(\s*;[^\n]*\n)",
        rf"\g<1>{value}\g<3>",
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"Could not find homebrew.onActivation.upgrade in {APPS}")
    APPS.write_text(new)
    print(f"Set Homebrew activation upgrades to {value} in {APPS.relative_to(ROOT)}")


def main(argv: list[str]) -> None:
    if len(argv) < 2 or argv[1] in {"-h", "--help", "help"}:
        usage(0)

    command = argv[1]
    if command in {"add", "rm"}:
        if len(argv) != 4:
            usage()
        if command == "add":
            add_item(argv[2], argv[3])
        else:
            rm_item(argv[2], argv[3])
        return

    if command == "set-brew-upgrade":
        if len(argv) != 3:
            usage()
        set_brew_upgrade(argv[2])
        return

    usage()


if __name__ == "__main__":
    main(sys.argv)
