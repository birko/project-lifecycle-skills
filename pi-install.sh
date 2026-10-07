#!/usr/bin/env bash
# Links BOTH skills/ and skills-pi/ into ~/.pi/agent/skills as symlinks, one per skill folder.
# Why links rather than copies: ADR 0009. Why that tree is pi-only and frozen: ADR 0010.
#
# Usage:  ./pi-install.sh      (idempotent; safe to re-run)

set -euo pipefail

# Git Bash's ln -s copies unless told otherwise; make it link or fail instead.
case "$(uname -s)" in MINGW*|MSYS*) export MSYS="${MSYS:+$MSYS }winsymlinks:nativestrict" ;; esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
target="$HOME/.pi/agent/skills"

mkdir -p "$target"

for repo_skills in "$repo_root/skills" "$repo_root/skills-pi"; do
    [ -d "$repo_skills" ] || continue
    for dir in "$repo_skills"/*/; do
        src="${dir%/}"
        name="$(basename "$src")"
        link="$target/$name"

        if [ -L "$link" ]; then
            if [ "$(cd "$link" 2>/dev/null && pwd -P || true)" = "$(cd "$src" && pwd -P)" ]; then
                echo "= $name (already linked)"
            else
                echo "warning: $name links elsewhere ($(readlink "$link")) — remove it and re-run to relink here" >&2
            fi
            continue
        fi

        if [ -e "$link" ]; then
            kind=directory; [ -d "$link" ] || kind=file
            echo "warning: $name: a $kind already exists at $link — move it aside and re-run" >&2
            continue
        fi

        if ! ln -s "$src" "$link" || [ ! -L "$link" ]; then
            [ -L "$link" ] || rm -rf -- "$link"   # only what this ln made: $link did not exist above
            echo "error: could not link $name — on Windows without symlink rights, run the .ps1 installer instead" >&2
            exit 1
        fi
        echo "+ $name -> $src"
    done
done

echo
echo "Done. Skills resolve from this repo via symlinks; edit here, they're live immediately."
