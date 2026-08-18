#!/usr/bin/env bash
# skills-lint — the repo's only automated gate.
#
#   1. every SKILL.md has frontmatter, and its `name` matches its folder
#   2. every [[wikilink]] resolves to a real skill (or a known runtime-provided reference)
#   3. every relative file link points at a file that exists
#
# Checks 2 and 3 ignore fenced code blocks and inline code spans: this repo teaches its own
# conventions by example, so illustrative links and wikilinks in samples are content, not defects.
#
# Run locally: bash .github/workflows/skills-lint.sh
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

fail=0
err() { printf '  ERROR %s\n' "$1"; fail=1; }

# References the runtime provides rather than this repo: built-in skills and agent types.
RUNTIME_REFS=" init update-config Explore "

# Strip fenced blocks (tracking fence length, so a ``` inside a ```` block does not close it)
# and then inline code spans.
strip_noise() {
  awk '
    {
      if (match($0, /^[[:space:]]*`+/)) {
        f = substr($0, RSTART, RLENGTH); gsub(/[^`]/, "", f); n = length(f)
        if (n >= 3) {
          if (!inblock)      { inblock = 1; flen = n; next }
          else if (n >= flen) { inblock = 0; next }
        }
      }
      if (!inblock) print
    }
  ' "$1" | sed 's/`[^`]*`//g'
}

for tree in skills skills-pi; do
  [ -d "$tree" ] || err "expected tree '$tree' is missing — the lint would pass vacuously"
done
skill_dirs=$(find skills skills-pi -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
n_skills=$(printf '%s' "$skill_dirs" | grep -c .)
# Resolve wikilinks against this list, never against the filesystem: NTFS is
# case-insensitive, so [ -d skills-pi/Code-Review ] is TRUE on Windows and the
# mis-cased reference this check exists to catch would pass locally.
skill_names=$(printf '%s
' "$skill_dirs" | sed 's|.*/||' | sort -u)
[ "$n_skills" -gt 0 ] || err "no skill folders found — refusing to report a vacuous pass"

printf '== 1. frontmatter ==\n'
for d in $skill_dirs; do
  f="$d/SKILL.md"; base=$(basename "$d")
  [ -f "$f" ] || { err "$d has no SKILL.md"; continue; }
  # Frontmatter is the block between the first and second '---', never a fixed line range.
  fm=$(awk 'NR==1 && $0=="---" {infm=1; next} infm && $0=="---" {exit} infm {print}' "$f")
  [ -n "$fm" ] || { err "$f does not start with frontmatter"; continue; }
  name=$(printf '%s\n' "$fm" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//')
  printf '%s\n' "$fm" | grep -q '^description:' || err "$f has no description:"
  if [ -z "$name" ]; then err "$f has no name:"
  elif [ "$name" != "$base" ]; then err "$f name '$name' does not match folder '$base'"; fi
done

printf '== 2. wikilinks ==\n'
find skills skills-pi -name '*.md' | sort | while read -r f; do
  strip_noise "$f" | grep -ohE '\[\[[^]|]+\]\]' | tr -d '[]' | sort -u | while read -r link; do
    [ -n "$link" ] || continue
    printf '%s
' "$skill_names" | grep -qx -- "$link" && continue
    case "$RUNTIME_REFS" in *" $link "*) continue ;; esac
    printf '  ERROR %s references [[%s]] — no such skill\n' "$f" "$link"
    printf 'x' >> .lint-fail
  done
done

printf '== 3. file references ==\n'
# Companion docs (tdd/*.md, REFERENCE.md) are scanned — a SKILL.md tells agents to read them.
# templates/ is excluded: its links resolve in the *generated* project, not here.
find skills skills-pi -name '*.md' ! -path '*/templates/*' | sort | while read -r f; do
  dir=$(dirname "$f")
  strip_noise "$f" | grep -ohE '\]\([^)]+\)' | sed 's/^](//; s/)$//' | sort -u | while read -r target; do
    case "$target" in http*|\#*|mailto:*|'') continue ;; esac
    target=$(printf '%s' "$target" | sed 's/[[:space:]]*"[^"]*"$//; s/[[:space:]]*'"'"'[^'"'"']*'"'"'$//')
    path="${target%%#*}"
    [ -n "$path" ] || continue
    [ -e "$dir/$path" ] && continue
    printf '  ERROR %s links to %s — not found relative to %s\n' "$f" "$path" "$dir"
    printf 'x' >> .lint-fail
  done
done

[ -s .lint-fail ] && fail=1
rm -f .lint-fail

if [ "$fail" -eq 0 ]; then
  printf '\nskills-lint: OK (%s skills)\n' "$n_skills"
else
  printf '\nskills-lint: FAILED\n'
fi
exit "$fail"
