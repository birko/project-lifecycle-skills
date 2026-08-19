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

printf '== 4. install roots (advisory) ==\n'
# ADVISORY — this check never touches `fail` and can never change the exit code. Two reasons, and
# the first is the real one: a missing junction is fixed by re-running an installer, which lives
# OUTSIDE this repo, so no diff can clear the finding and a repo gate must not block on it. Second,
# the roots do not exist on the CI runner, so a fatal check here would make this gate's meaning
# depend on which machine ran it.
# Roots are overridable because the regression suite has to fabricate them — CI has none to find,
# which would otherwise make every case below unwritable.
CLAUDE_SKILLS_ROOT="${CLAUDE_SKILLS_ROOT:-$HOME/.claude/skills}"
PI_SKILLS_ROOT="${PI_SKILLS_ROOT:-$HOME/.pi/agent/skills}"
repo_name=$(basename "$(pwd -P)")

advise() { printf '  ~ %s\n' "$1"; }

# `skills/` is linked into BOTH roots; `skills-pi/` into the pi root ONLY — the real built-ins live
# in the Claude root and the stubs would shadow them. That asymmetry is handled by which trees each
# call passes, so skills-pi/ is never compared against the Claude root and can never be reported
# missing from it.
check_root() {
  root=$1; shift
  if [ ! -d "$root" ]; then
    advise "skipped $root — not present on this machine (a runtime you have not installed is not drift)"
    return
  fi
  # `tree` and `d` are also loop variables earlier in this script; localize them so check 4 cannot
  # clobber them. It runs last today, so nothing breaks — but that is position, not safety.
  local missing=0 stale=0 total=0 name t names="" tree d l
  for tree in "$@"; do
    for d in "$tree"/*/; do
      [ -d "$d" ] || continue
      name=$(basename "${d%/}")
      total=$((total+1))
      # -L as well as -e: a link that exists but dangles is stale, not missing, and is reported below.
      if [ ! -e "$root/$name" ] && [ ! -L "$root/$name" ]; then
        names="$names $name"
        missing=$((missing+1))
      fi
    done
  done
  # "Nothing is linked" is ONE condition, not N findings. Naming all 16 skills for a root the
  # installer has simply never been run against buries the case that matters — a single skill that
  # drifted — under a wall of text. Measured in the drill: 30+ lines for two empty roots.
  if [ "$missing" -gt 0 ] && [ "$missing" -eq "$total" ]; then
    advise "$root exists but nothing is linked into it ($total skills) — run the installer"
  else
    for name in $names; do
      advise "$name is not linked into $root — re-run the installer so the skill resolves"
    done
  fi
  for l in "$root"/*; do
    [ -L "$l" ] || continue
    # Read the RAW target. A dangling link cannot be canonicalised, so resolving here would lose
    # exactly the case this half of the check exists to find.
    t=$(readlink "$l") || continue
    # Only links that point into THIS repo are ours to judge; these roots also hold the user's own
    # unrelated skills, and flagging those would make the check untrustworthy.
    #
    # Matched on the target's TAIL, not a `$(pwd -P)` prefix. A raw link target is not guaranteed to
    # share a path form with pwd: measured under Git Bash, a junction into the Windows temp reads back
    # as /tmp/... while pwd -P gives /c/Users/.../Temp/... — same directory, no common prefix. A prefix
    # test therefore skips the link as "not ours" and silently loses the stale case, which is the whole
    # point of this half. (If two clones share a basename, a link into the other clone is reported here;
    # that is worth surfacing anyway — the installers already warn "links elsewhere" for it.)
    case "$t" in
      */"$repo_name"/skills/*|*/"$repo_name"/skills-pi/*) ;;
      *) continue ;;
    esac
    if [ ! -d "$t" ]; then
      advise "$(basename "$l") in $root points at $t, which no longer exists — stale junction"
      stale=$((stale+1))
    fi
  done
  if [ "$missing" -eq 0 ] && [ "$stale" -eq 0 ]; then
    advise "$root is in sync"
  fi
}

check_root "$CLAUDE_SKILLS_ROOT" skills
check_root "$PI_SKILLS_ROOT" skills skills-pi

[ -s "$FAILFILE" ] && fail=1
if [ "$fail" -eq 0 ]; then
  printf '\nskills-lint: OK (%s skills)\n' "$n_skills"
else
  printf '\nskills-lint: FAILED\n'
fi
exit "$fail"
