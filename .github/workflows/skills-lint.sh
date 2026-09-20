#!/usr/bin/env bash
# skills-lint — the repo's only automated gate.
#
# Each check announces itself below as `== N. name ==`; those banners are the inventory — do not
# restate them here, because a copy goes stale the next time a check is inserted.
#
# The wikilink and file-reference checks ignore fenced blocks and inline code spans: this repo
# teaches its own conventions by example, so illustrative links in samples are content, not defects.
# Named, not numbered, for the reason two lines above.
#
# Run locally: bash .github/workflows/skills-lint.sh
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

# Failures are recorded in a temp file because the checks that run inside `find | while` and
# `grep | while` subshells would lose a plain `fail=1` when the subshell exits. It lives outside
# the repo so an interrupted run can never poison a later one, and can never be committed by
# `git add -A`.
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

printf '== 4. cross-skill flags ==\n'
# A skill that tells you to run another skill's verb WITH a flag is asserting that flag exists.
# Nothing enforced that: rename or typo the flag on either side and the caller keeps passing an
# argument the receiver silently ignores. This check is preventive rather than remedial — an empty
# finding list is the expected state here, not a broken check (measurement: TASK-045).
#
# The receiving side is read WHOLE rather than from an "## Args" block, because two
# declaration styles are in use — bullets in most verbs, and an invocation table in
# tasks/verbs/import.md. Keying on bullets alone reported import's real flags as missing.
#
# The skill name is NOT a hard-coded list. An alternation of today's skills would go quietly stale
# the day a skill is added — the restated-list defect this repo lints for elsewhere — and could not be
# exercised on a fixture whose skills are named something else. Match any `/word verb --flag` and let
# the existence of `skills/<word>/` decide whether it is one of ours; a stray `/usr/bin/x y --z` in
# prose resolves to no skill folder and is skipped.
# An argument may sit BETWEEN the verb and its flag, and an invocation may carry MORE THAN ONE
# flag. Matching only `/skill verb --flag` missed both — TASK-108 carries the measurement and the
# invocations it names. The mechanic behind the second half stays here because it lives nowhere
# else: `grep -o` ends its match at the first flag, so a later flag on the same invocation is
# invisible even when the first one matched.
#
# WHAT AN ARGUMENT MAY LOOK LIKE IS THE WHOLE DESIGN, because this check is fatal and prose is
# not a diff anyone can fix. A first attempt allowed any bare word between verb and flag; that
# reads ordinary prose as an invocation -- `The /beta go step runs before the --nosuch cleanup.`
# errored -- and `skills/` already carries unbackticked `/skill verb <word>` sentences that would
# trip it the day one gained a flag. So an argument is a PLACEHOLDER (`<areas>`, `{{ID}}`), an
# identifier or number starting upper-case or numeric (`FEATURE-NNN`, `3`), or an ellipsis --
# plus AT MOST ONE lowercase word, in the subcommand slot (`/tasks new task ...`). Prose runs
# several lowercase words together and therefore cannot match; an invocation does not.
# That one-lowercase-word ceiling is deliberate, not an oversight: `/beta go a b c d e f --x`
# is prose by construction, and widening it to reach such a line would reopen the false positive.
ARG_RE='(<[^<>]*>|\{\{[^{}]*\}\}|[A-Z0-9][A-Za-z0-9_-]*|\.\.\.)'
grep -rnoE "/[a-z][a-z-]* [a-z][a-z-]*( [a-z][a-z-]*)?( $ARG_RE)*( --[a-z-]+(=[^ ]*)?( $ARG_RE)*)+" skills/ 2>/dev/null \
| while IFS= read -r hit; do
  src=${hit%%:*}
  inv=${hit#*:}; inv=${inv#*:}
  skill=$(printf '%s' "$inv" | sed -E 's|^/([a-z-]+).*|\1|')
  verb=$(printf '%s' "$inv"  | sed -E 's|^/[a-z-]+ ([a-z-]+).*|\1|')
  recv="skills/$skill/verbs/$verb.md"
  [ -e "$recv" ] || recv="skills/$skill/SKILL.md"
  [ -e "$recv" ] || continue
  # ANCHORED, not a bare substring test. `grep -qF -- "$flag"` matched --unattend inside
  # --unattended and --dry inside --dry-run, so a truncated or prefix-colliding flag shipped green
  # on the repo's only gate. Bound both sides by the flag's own character class. Still existence
  # only, never semantics: a receiver naming a flag in prose to say it is UNSUPPORTED still
  # satisfies this, which AGENTS.md scopes the check out of deliberately.
  #
  # EVERY flag on the invocation, not just the first -- and each must be SPACE-ANCHORED. Grepping
  # `--[a-z-]+` over the whole match reported `--known` out of an argument like `well--known`.
  printf '%s' "$inv" | grep -oE ' --[a-z-]+' | sed 's/^ //' | while IFS= read -r flag; do
    grep -qE -- "(^|[^a-z-])${flag}([^a-z-]|$)" "$recv" || \
      suberr "$src passes $flag to /$skill $verb — not declared in $recv"
  done
done

printf '== 5. universal-conventions copies ==\n'
# FATAL, unlike the advisory install-roots check below — the remedy here is a diff in this repo.
# Why the rule exists in two files and why neither can point at the other: AGENTS.md § "Where the
# same prose must exist in two files", and FEATURE-002 D13.
UNIV_FILE=skills/new-project/templates/CONVENTIONS-universal.md
RULE_START='<!-- comment-rule:start -->'
RULE_END='<!-- comment-rule:end -->'

rule_block() { # $1 = file. Empty output means "no delimited block here".
  [ -f "$1" ] || return 0
  # The marker must be ALONE on its line. A substring match instead captures from the first place the
  # file merely *mentions* the marker — and AGENTS.md documents this very convention in prose a few
  # hundred lines above the block it describes, so the substring version reported the two copies as
  # differing the moment the convention was written down.
  awk -v s="$RULE_START" -v e="$RULE_END" '
    function bare(x) { gsub(/^[ 	]+|[ 	]+$/, "", x); return x }
    bare($0) == s { inb = 1 }
    inb           { print }
    bare($0) == e { if (inb) exit }
  ' "$1"
}

univ_block=$(rule_block "$UNIV_FILE")
agents_block=$(rule_block AGENTS.md)

if [ -z "$univ_block" ] && [ -z "$agents_block" ]; then
  # Printed rather than skipped in silence: a reader cannot tell "no pair to check" from "the check
  # did not run", and the second is how a gate quietly stops gating.
  printf '  no universal-conventions pair in this tree — nothing to compare\n'
elif [ -z "$agents_block" ]; then
  err "$UNIV_FILE carries the comment-rule block but AGENTS.md does not — this repo ships a rule it does not follow"
elif [ -z "$univ_block" ]; then
  err "AGENTS.md carries the comment-rule block but $UNIV_FILE does not — consumers would receive nothing"
elif [ "$univ_block" != "$agents_block" ]; then
  err "the comment-rule block differs between AGENTS.md and $UNIV_FILE — they must be byte-identical, or every project is linted against different words"
else
  printf '  AGENTS.md and %s agree (%s lines)\n' "$UNIV_FILE" "$(printf '%s\n' "$univ_block" | wc -l | tr -d ' ')"
fi

printf '== 6. install roots (advisory) ==\n'
# ADVISORY — never touches `fail`, so it cannot change the exit code, and must not be made to.
# Why it has to stay that way: AGENTS.md § Testing.
# Roots are overridable because the regression suite has to fabricate them — CI has none to find,
# which would otherwise make every case below unwritable.
CLAUDE_SKILLS_ROOT="${CLAUDE_SKILLS_ROOT:-$HOME/.claude/skills}"
PI_SKILLS_ROOT="${PI_SKILLS_ROOT:-$HOME/.pi/agent/skills}"
repo_name=$(basename "$(pwd -P)")

advise() { printf '  ~ %s\n' "$1"; }

# `skills/` is linked into BOTH roots; `skills-pi/` into the pi root ONLY (ADR 0010). That asymmetry
# is handled by which trees each call passes, so skills-pi/ is never compared against the Claude root
# and can never be reported missing from it.
check_root() {
  root=$1; shift
  if [ ! -d "$root" ]; then
    advise "skipped $root — not present on this machine (a runtime you have not installed is not drift)"
    return
  fi
  # `tree` and `d` are also loop variables earlier in this script; localize them so check 4 cannot
  # clobber them. It runs last today, so nothing breaks — but that is position, not safety.
  local missing=0 stale=0 shadow=0 total=0 name t tree_of allowed names="" tree d l
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
    #
    # Which of this repo's trees does the link point into? Derived from the path, never from a list
    # of tree names — a hard-coded `skills|skills-pi` alternation goes wrong silently the day a third
    # tree is added, and this check would keep passing while missing it.
    case "$t" in
      # `##` not `#`: shortest-prefix removal takes the FIRST occurrence of the repo name, so a
      # layout that repeats it as an ancestor (a worktree at <repo>/wt/<repo>, a clone at
      # ~/src/<repo>/<repo>) would yield the wrong tree and report every in-repo junction as a shadow.
      # Longest-prefix matches the tail, which is what this case needs.
      */"$repo_name"/*) tree_of=${t##*/"$repo_name"/}; tree_of=${tree_of%%/*} ;;
      *) continue ;;
    esac
    # A link pointing into a tree this root was NOT asked to hold is a SHADOW, not a stale link: its
    # source exists, so the staleness test below passes it as healthy. That is the whole gap — the
    # Claude root is called with `skills` only, so a `skills-pi` junction there resolves the runtime's
    # own built-in review passes to this repo's fallback stubs. Nothing errors and the output still
    # looks like a review, which is why no other check can see it.
    allowed=0
    # basename: the argument is the caller's string, `$tree_of` is derived from a path. They match
    # today only because both call sites pass bare relative names — `"$PWD/skills"` is an equally
    # valid argument for the loop above, and would leave `allowed` permanently 0, reporting every
    # in-repo junction as a shadow.
    for tree in "$@"; do [ "$(basename "$tree")" = "$tree_of" ] && allowed=1; done
    if [ "$allowed" -eq 0 ]; then
      advise "$(basename "$l") in $root points into $tree_of/, which is never linked into this root — remove the junction (a skills-pi/ stub here shadows the runtime's own review pass)"
      shadow=$((shadow+1))
      # NO `continue`: a shadow can also dangle, and both facts are separately actionable. Skipping
      # the staleness test here would report a junction as shadowing something that is already gone.
    fi
    if [ ! -d "$t" ]; then
      advise "$(basename "$l") in $root points at $t, which no longer exists — stale junction"
      stale=$((stale+1))
    fi
  done
  # Reported AFTER the link loop, because "nothing is linked" is only true if nothing is linked —
  # a root holding nothing but shadow junctions is not empty, and telling the user to run the
  # installer there adds the missing links and leaves the shadow in place. The two advisories would
  # contradict each other.
  #
  # "Nothing is linked" is ONE condition, not N findings. Naming every skill for a root the
  # installer has simply never been run against buries the case that matters — a single skill that
  # drifted — under a wall of text (TASK-016).
  if [ "$missing" -gt 0 ] && [ "$missing" -eq "$total" ]; then
    # Kept as a collapse even when a shadow is present: gating it on `shadow -eq 0` sent an otherwise
    # unlinked root down the per-skill branch and printed one line per skill — the wall this
    # collapse exists to remove, and reachable exactly in the TASK-037 case (a stale skills-pi
    # junction in a root where skills/ was never linked). The contradiction the gate was meant to fix
    # was the WORDING, so fix the wording: say what is not linked rather than that nothing is.
    if [ "$shadow" -gt 0 ]; then
      advise "$root has none of the $total expected skills linked (only shadow junctions) — run the installer, and remove the shadows reported above"
    else
      advise "$root exists but nothing is linked into it ($total skills) — run the installer"
    fi
  else
    for name in $names; do
      advise "$name is not linked into $root — re-run the installer so the skill resolves"
    done
  fi
  if [ "$missing" -eq 0 ] && [ "$stale" -eq 0 ] && [ "$shadow" -eq 0 ]; then
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
