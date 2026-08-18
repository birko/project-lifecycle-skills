#!/usr/bin/env bash
# skills-lint — the repo's only automated gate.
#
# There is nothing to compile here, so this checks the three invariants that actually break:
#   1. every SKILL.md has frontmatter, and its `name` matches its folder
#   2. every [[wikilink]] resolves to a real skill (or a known runtime-provided one)
#   3. every relative file link in a SKILL.md / verbs file points at a file that exists
#
# Run locally: bash .github/workflows/skills-lint.sh
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

fail=0
err() { printf '  ERROR %s\n' "$1"; fail=1; }

# Skills provided by the runtime, not by this repo. A [[link]] to one of these is legitimate.
RUNTIME_SKILLS=" init update-config "

skill_dirs=$(find skills skills-pi -mindepth 1 -maxdepth 1 -type d | sort)

printf '== 1. frontmatter ==\n'
for d in $skill_dirs; do
  f="$d/SKILL.md"
  base=$(basename "$d")
  [ -f "$f" ] || { err "$d has no SKILL.md"; continue; }
  [ "$(head -n1 "$f")" = "---" ] || err "$f does not start with frontmatter"
  name=$(sed -n '2,20p' "$f" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//')
  desc=$(sed -n '2,20p' "$f" | grep -m1 '^description:')
  [ -n "$name" ] || err "$f has no name:"
  [ -n "$desc" ] || err "$f has no description:"
  [ -z "$name" ] || [ "$name" = "$base" ] || err "$f name '$name' does not match folder '$base'"
done

printf '== 2. wikilinks ==\n'
for f in $(find skills skills-pi -name '*.md' | sort); do
  for link in $(grep -ohE '\[\[[a-z0-9-]+\]\]' "$f" | tr -d '[]' | sort -u); do
    if [ -d "skills/$link" ] || [ -d "skills-pi/$link" ]; then continue; fi
    case "$RUNTIME_SKILLS" in *" $link "*) continue ;; esac
    err "$f references [[$link]] — no such skill"
  done
done

printf '== 3. file references ==\n'
for f in $(find skills skills-pi -name 'SKILL.md' -o -path '*/verbs/*.md' | sort); do
  dir=$(dirname "$f")
  # Strip fenced code blocks first — illustrative example paths in them are not real links.
  body=$(awk '/^[[:space:]]*```/ {inblock = !inblock; next} !inblock' "$f")
  for target in $(printf '%s
' "$body" | grep -ohE '\]\([^)]+\)' | sed 's/^](//; s/)$//' | sort -u); do
    case "$target" in
      http*|\#*|mailto:*) continue ;;
    esac
    path="${target%%#*}"
    [ -n "$path" ] || continue
    [ -e "$dir/$path" ] || err "$f links to '$path' — not found relative to $dir"
  done
done

if [ "$fail" -eq 0 ]; then
  printf '\nskills-lint: OK (%s skills)\n' "$(printf '%s\n' $skill_dirs | wc -l | tr -d ' ')"
else
  printf '\nskills-lint: FAILED\n'
fi
exit "$fail"
