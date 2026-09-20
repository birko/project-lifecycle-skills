#!/usr/bin/env bash
# Links skills/ into ~/.claude/skills as symlinks, one per skill folder.
# Why links rather than copies: ADR 0009.
#
# Usage:  ./install.sh          (idempotent; safe to re-run)

set -euo pipefail

repo_skills="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd -P)"
target="$HOME/.claude/skills"

mkdir -p "$target"

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
        echo "warning: $name: a real directory already exists at $link — move it aside and re-run" >&2
        continue
    fi

    ln -s "$src" "$link"
    echo "+ $name -> $src"
done

echo
echo "Done. Skills resolve from this repo via symlinks; edit here, they're live immediately."
