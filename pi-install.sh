#!/usr/bin/env bash
# Installs the lifecycle skills into ~/.pi/agent/skills as symlinks pointing
# back into this repo — the repo stays the single source of truth, so
# `git pull` updates the live skills with no re-install.
#
# Links BOTH skills/ (the shared set, same as install.sh) AND skills-pi/ —
# pi-only stubs of the Claude Code built-ins (code-review, review,
# security-review) so pi resolves those references instead of skipping the
# review gates. skills-pi/ must NEVER be linked into ~/.claude/skills: there
# the real built-ins exist and the stubs would shadow them.
#
# Usage:  ./pi-install.sh      (idempotent; safe to re-run)

set -euo pipefail

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
            echo "warning: $name: a real directory already exists at $link — move it aside and re-run" >&2
            continue
        fi

        ln -s "$src" "$link"
        echo "+ $name -> $src"
    done
done

echo
echo "Done. Skills resolve from this repo via symlinks; edit here, they're live immediately."
