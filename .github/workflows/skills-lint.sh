#!/usr/bin/env bash
# skills-lint — the repo's only automated gate.
#
#   1. every SKILL.md has frontmatter, and its `name` matches its folder
#   2. every [[wikilink]] resolves to a real skill (or a known runtime-provided reference)
#   3. every relative file link points at a file that exists
#
# Checks 2 and 3 ignore fenced blocks and inline code spans: this repo teaches its own
# conventions by example, so illustrative links in samples are content, not defects.
#
# Run locally: bash .github/workflows/skills-lint.sh
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

# Failures are recorded in a temp file because checks 2 and 3 run inside `find | while`
# subshells. It lives outside the repo so an interrupted run can never poison a later one,
# and can never be committed by `git add -A`.
FAILFILE=$(mktemp); trap 'rm -f "$FAILFILE"' EXIT
fail=0
err() { printf '  ERROR %s\n' "$1"; fail=1; }
suberr() { printf '  ERROR %s\n' "$1"; printf 'x' >> "$FAILFILE"; }

RUNTIME_REFS=" init update-config Explore "

# Strip fenced blocks (backtick or tilde, tracking fence length so an inner ``` does not
# close a ```` block), then inline code spans (double-backtick first, then single).
strip_noise() {
  awk '
    {
      if (match($0, /^[[:space:]]*(`+|~+)/)) {
        f = substr($0, RSTART, RLENGTH); gsub(/[^`~]/, "", f); n = length(f)
        c = substr(f, 1, 1)
        if (n >= 3) {
          if (!inblock)                       { inblock = 1; flen = n; fch = c; next }
          else if (c == fch && n >= flen)     { inblock = 0; next }
        }
      }
      if (!inblock) print
    }
    END { if (inblock) print "SKILLS_LINT_UNBALANCED_FENCE" }
  ' "$1" | sed 's/``[^`]*``//g; s/`[^`]*`//g'
}

# Case-exact existence test: NTFS is case-insensitive, so plain [ -e ] passes a mis-cased
# link locally and fails only on the Linux runner. find's -name is case-sensitive everywhere.
exists_exact() {
  [ -e "$1" ] || return 1
  local d b; d=$(dirname "$1"); b=$(basename "$1")
  [ -n "$(find "$d" -maxdepth 1 -name "$b" 2>/dev/null)" ]
}

for tree in skills skills-pi; do
  [ -d "$tree" ] || err "expected tree '$tree' is missing — the lint would pass vacuously"
done
skill_dirs=$(find skills skills-pi -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
n_skills=$(printf '%s' "$skill_dirs" | grep -c .)
[ "$n_skills" -gt 0 ] || err "no skill folders found — refusing to report a vacuous pass"
skill_names=$(printf '%s\n' "$skill_dirs" | sed 's|.*/||' | sort -u)

printf '== 1. frontmatter ==\n'
for d in $skill_dirs; do
  f="$d/SKILL.md"; base=$(basename "$d")
  [ -f "$f" ] || { err "$d has no SKILL.md"; continue; }
  fm=$(awk 'NR==1 && $0=="---" {infm=1; next} infm && $0=="---" {exit} infm {print}' "$f")
  [ -n "$fm" ] || { err "$f does not start with frontmatter"; continue; }
  name=$(printf '%s\n' "$fm" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//')
  printf '%s\n' "$fm" | grep -q '^description:' || err "$f has no description:"
  if [ -z "$name" ]; then err "$f has no name:"
  elif [ "$name" != "$base" ]; then err "$f name '$name' does not match folder '$base'"; fi
done

printf '== 2. wikilinks ==\n'
find skills skills-pi -name '*.md' | sort | while read -r f; do
  body=$(strip_noise "$f")
  # An unclosed fence would swallow the rest of the file and the gate would pass vacuously.
  case "$body" in *SKILLS_LINT_UNBALANCED_FENCE*) suberr "$f has an unbalanced code fence — the rest of the file cannot be checked" ;; esac
  # Aliased links ([[name|text]]) are checked on the name half, never skipped.
  printf '%s\n' "$body" | grep -ohE '\[\[[^]]+\]\]' | tr -d '[]' | cut -d'|' -f1 | sort -u | while read -r link; do
    [ -n "$link" ] || continue
    printf '%s\n' "$skill_names" | grep -qxF -- "$link" && continue
    case "$RUNTIME_REFS" in *" $link "*) continue ;; esac
    suberr "$f references [[$link]] — no such skill"
  done
done

printf '== 3. file references ==\n'
# Companion docs are scanned — a SKILL.md tells agents to read them. templates/ is excluded:
# its links resolve in the *generated* project, not here.
find skills skills-pi -name '*.md' ! -path '*/templates/*' | sort | while read -r f; do
  dir=$(dirname "$f")
  strip_noise "$f" | grep -ohE '\]\([^)]+\)' | sed 's/^](//; s/)$//' | sort -u | while read -r target; do
    case "$target" in http*|\#*|mailto:*|'') continue ;; esac
    target=$(printf '%s' "$target" | sed 's/[[:space:]]*"[^"]*"$//; s/[[:space:]]*'"'"'[^'"'"']*'"'"'$//')
    path="${target%%#*}"
    [ -n "$path" ] || continue
    # A leading / is repo-root-relative, not a child of this file's directory.
    case "$path" in /*) full=".${path}" ;; *) full="$dir/$path" ;; esac
    exists_exact "$full" && continue
    suberr "$f links to $path — not found (case-sensitively) from $dir"
  done
done

[ -s "$FAILFILE" ] && fail=1
if [ "$fail" -eq 0 ]; then
  printf '\nskills-lint: OK (%s skills)\n' "$n_skills"
else
  printf '\nskills-lint: FAILED\n'
fi
exit "$fail"
