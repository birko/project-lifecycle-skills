#!/usr/bin/env bash
# skills-lint-test — regression tests for skills-lint.sh, the repo's only gate (AGENTS.md § Testing).
#
# Each case below builds a throwaway fixture, mutates one thing, and asserts the lint's exit code,
# its output, or both.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
LINT="$(pwd)/.github/workflows/skills-lint.sh"

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0

# Check 6 (install roots) reads $HOME by default. Point it at nothing so every case below is
# hermetic: a suite whose result depends on which skills the developer happens to have installed
# is not a test. The install-root cases override these per case.
export CLAUDE_SKILLS_ROOT="$WORK/no-such-root" PI_SKILLS_ROOT="$WORK/no-such-root"
bt='`'

build() { # $1 = target dir — a minimal, valid two-tree repo
  rm -rf "$1"; mkdir -p "$1/.github/workflows" "$1/skills/alpha/verbs" "$1/skills/beta" "$1/skills-pi/gamma"
  cp "$LINT" "$1/.github/workflows/"
  printf -- '---\nname: alpha\ndescription: d\n---\n\nSee [go](verbs/go.md) and [[beta]] and [[gamma]].\n' > "$1/skills/alpha/SKILL.md"
  printf -- '# go\n\nSee [back](../SKILL.md).\n' > "$1/skills/alpha/verbs/go.md"
  printf -- '# companion\n\nSee [back](SKILL.md).\n' > "$1/skills/alpha/companion.md"
  printf -- '---\nname: beta\ndescription: d\n---\n\nBeta.\n' > "$1/skills/beta/SKILL.md"
  printf -- '---\nname: gamma\ndescription: d\n---\n\nGamma.\n' > "$1/skills-pi/gamma/SKILL.md"
}

case_is() { # name, expected(0|1), mutation function name
  local name="$1" want="$2" mut="$3" d="$WORK/case"
  build "$d"; "$mut" "$d"
  ( cd "$d" && bash .github/workflows/skills-lint.sh >/dev/null 2>&1 ); local got=$?
  [ "$got" -ne 0 ] && got=1
  if [ "$got" = "$want" ]; then printf '  ok    %s\n' "$name"; pass=$((pass+1))
  else printf '  FAIL  %s (exit %s, wanted %s)\n' "$name" "$got" "$want"; fail=$((fail+1)); fi
}

mk_link() { # $1 = link, $2 = existing target dir. A symlink on POSIX; a junction on Windows.
  ln -s "$2" "$1" 2>/dev/null
  [ -L "$1" ] && return 0
  # `ln -s` copied instead of linking: fall back to install.ps1's junction (why, and the order: AGENTS.md § Testing).
  rm -rf "$1"
  command -v cygpath >/dev/null 2>&1 || return 1
  powershell -NoProfile -Command "New-Item -ItemType Junction -Path '$(cygpath -w "$1")' -Target '$(cygpath -w "$2")' | Out-Null" >/dev/null 2>&1
  [ -L "$1" ]
}

# `case_is` sees only the exit code, which check 6 never touches (advisory — AGENTS.md § Testing).
# These assert on OUTPUT and still require exit 0 — an advisory that began failing the build would
# itself be a regression.
roots_run() { # $1 = fixture dir; echoes the lint's combined output
  ( cd "$1" && CLAUDE_SKILLS_ROOT="$1/roots/claude" PI_SKILLS_ROOT="$1/roots/pi" bash .github/workflows/skills-lint.sh 2>&1 )
}
case_says() { # name, mutation, substring that MUST appear
  local name="$1" mut="$2" pat="$3" d="$WORK/case" out rc
  build "$d"; "$mut" "$d"
  out=$(roots_run "$d"); rc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF -- "$pat"; then
    printf '  ok    %s\n' "$name"; pass=$((pass+1))
  else
    printf '  FAIL  %s (exit %s; wanted output to contain: %s)\n' "$name" "$rc" "$pat"; fail=$((fail+1))
  fi
}
case_silent() { # name, mutation, substring that must NOT appear
  local name="$1" mut="$2" pat="$3" d="$WORK/case" out rc
  build "$d"; "$mut" "$d"
  out=$(roots_run "$d"); rc=$?
  # Require check 6 to have RUN before trusting the absence (why: AGENTS.md § Testing).
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF -- '== 6. install roots' && ! printf '%s' "$out" | grep -qF -- "$pat"; then
    printf '  ok    %s\n' "$name"; pass=$((pass+1))
  else
    printf '  FAIL  %s (exit %s; wanted check 6 to run and output NOT to contain: %s)\n' "$name" "$rc" "$pat"; fail=$((fail+1))
  fi
}

case_fails_saying() { # name, mutation, substring that MUST appear on a FAILING run
  local name="$1" mut="$2" pat="$3" d="$WORK/case" out rc
  build "$d"; "$mut" "$d"
  out=$( cd "$d" && bash .github/workflows/skills-lint.sh 2>&1 ); rc=$?
  # Both halves matter: a check that fails with the wrong message sends the reader to the wrong file,
  # and a check that prints the right message while exiting 0 is not a gate.
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF -- "$pat"; then
    printf '  ok    %s
' "$name"; pass=$((pass+1))
  else
    printf '  FAIL  %s (exit %s; wanted non-zero AND output to contain: %s)
' "$name" "$rc" "$pat"; fail=$((fail+1))
  fi
}

m_noop()      { :; }
# check 4 — cross-skill flags. alpha's router tells you to run beta's verb with a flag; the pair of
# mutations is the point: the first must fail, the second must not, or the check is either blind or
# indiscriminate.
m_flagbad()   { printf -- '
Run `/beta go --nosuch` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
m_flagok()    { printf -- '
Run `/beta go --real` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
# A receiver declaring its flags in a TABLE, not bullets: pins check 4's whole-file read (why: the
# check-4 header in skills-lint.sh).
m_flagtable() { printf -- '
Run `/beta go --tabled` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

| Invocation | Purpose |
|---|---|
| `/beta go --tabled` | a thing |
' > "$1/skills/beta/verbs/go.md"; }
# A flag whose name is a PREFIX of a declared one must NOT pass. `grep -qF` matched --unattend
# inside --unattended, so a truncated flag shipped green on the repo's only gate.
m_flagprefix(){ printf -- '
Run `/beta go --unattend` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--unattended` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
# The two below — an ARGUMENT between the verb and its flag: an id, a placeholder or a subcommand
# before the flag hides the whole invocation from a check matching only `/skill verb --flag`
# (TASK-108). EVIDENCE: the first passes against the old lint.
m_flagargbad(){ printf -- '
Run `/beta go <target> --nosuch` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
m_flagargok() { printf -- '
Run `/beta go <target> --real` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
# A SECOND flag on the same invocation: `grep -o` ends the match at the first flag, so the second
# goes unchecked. EVIDENCE: passes against the old lint. The first flag must be a DECLARED one — only
# then does the old lint find the receiver, check `--real`, pass, and never reach `--nosuch`.
m_flagsecond(){ printf -- '
Run `/beta go --real VALUE --nosuch` when done.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
# PROSE read as an invocation — the false positive the widening must not introduce (why it outweighs
# the gap: TASK-108). EVIDENCE: errors against a bare-word ARG_RE, the over-wide pattern it guards
# against. UNBACKTICKED and several lowercase words, both deliberate — backticks make the argument
# repetition unreachable, and the case could then not fail under ANY widening.
m_flagprose() { printf -- '
The /beta go step runs before the --nosuch cleanup in your log.
' >> "$1/skills/alpha/SKILL.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
# The two below — COVERAGE this check already has, against the two easy ways to lose it: skipping
# templates/ (as check 3 does) and filtering to *.md. PIN, not evidence: neither fails against the
# old lint. Both guard something real:
# new-project/templates/CLAUDE.seed.md carries `/tasks pick --feature` and SHIPS to consumers, and
# skills/ holds README.md.tmpl files a *.md filter would silently drop.
m_flagtemplatereal(){ mkdir -p "$1/skills/alpha/templates"
                printf -- '# seed

Run `/beta go --nosuch` in the new project.
' > "$1/skills/alpha/templates/seed.md"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
m_flagtmplext(){ mkdir -p "$1/skills/alpha/templates"
                printf -- '# seed

Run `/beta go --nosuch` here.
' > "$1/skills/alpha/templates/README.md.tmpl"
                mkdir -p "$1/skills/beta/verbs"
                printf -- '# go

- `--real` does a thing.
' > "$1/skills/beta/verbs/go.md"; }
# A flag aimed at something that is not a skill must be ignored, not reported.
m_flagforeign() { printf -- '
Run `/usr/bin/thing go --whatever` first.
' >> "$1/skills/alpha/SKILL.md"; }
m_miscased()  { printf '\nSee [[Beta]].\n' >> "$1/skills/alpha/SKILL.md"; }
m_underscore(){ printf '\nSee [[jira_task]].\n' >> "$1/skills/alpha/SKILL.md"; }
m_bogus()     { printf '\nSee [[no-such-skill]].\n' >> "$1/skills/alpha/SKILL.md"; }
m_mismatch()  { sed -i 's/^name: beta/name: not-beta/' "$1/skills/beta/SKILL.md"; }
m_fencename() { printf -- '---\ndescription: d\n---\n\n%s%s%syaml\nname: beta\n%s%s%s\n' "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" > "$1/skills/beta/SKILL.md"; }
m_nodesc()    { printf -- '---\nname: beta\n---\n\nx\n' > "$1/skills/beta/SKILL.md"; }
m_noskill()   { mkdir "$1/skills/orphan"; }
m_badlink()   { printf '\nSee [x](nope.md).\n' >> "$1/skills/alpha/companion.md"; }
m_notree()    { rm -rf "$1/skills-pi"; }
m_titled()    { printf '\nSee [x](SKILL.md "The title").\n' >> "$1/skills/alpha/companion.md"; }
m_anchor()    { printf '\nSee [x](SKILL.md#a-section).\n' >> "$1/skills/alpha/companion.md"; }
m_fencelink() { printf '\n%s%s%smarkdown\nSee [[my-new-skill]].\n%s%s%s\n' "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" >> "$1/skills/alpha/SKILL.md"; }
m_codespan()  { printf '\nWrite %s[label](example-path.md)%s like so.\n' "$bt" "$bt" >> "$1/skills/alpha/companion.md"; }
m_nested()    { printf '\n%s%s%s%smd\n%s%s%s\nSee [x](inside.md) and [[nope-skill]].\n%s%s%s\n%s%s%s%s\n' "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" "$bt" >> "$1/skills/alpha/companion.md"; }
m_template()  { mkdir -p "$1/skills/alpha/templates"; printf '# seed\n\nSee [t](tasks/README.md).\n' > "$1/skills/alpha/templates/seed.md"; }

printf 'A clean fixture must pass\n'
case_is "clean fixture"                    0 m_noop
printf 'Broken input must fail\n'
case_is "mis-cased wikilink"               1 m_miscased
case_is "underscore wikilink"              1 m_underscore
case_is "unknown wikilink"                 1 m_bogus
case_is "name does not match folder"       1 m_mismatch
case_is "name only inside a fenced block"  1 m_fencename
case_is "missing description"              1 m_nodesc

printf 'Check 4 — cross-skill flags
'
case_is   "flag not declared in receiving verb"  1 m_flagbad
case_is   "flag declared in receiving verb"      0 m_flagok
case_is   "receiver declares flags in a table"   0 m_flagtable
case_is   "flag aimed at a non-skill path"       0 m_flagforeign
case_is   "flag is a prefix of a declared flag"  1 m_flagprefix
case_is   "arg between verb and flag, undeclared" 1 m_flagargbad
case_is   "arg between verb and flag, declared"   0 m_flagargok
case_is   "second flag on one invocation"         1 m_flagsecond
case_is   "prose between verb and distant flag"   0 m_flagprose
case_is   "template naming a real skill is checked" 1 m_flagtemplatereal
case_is   "invocation in a non-.md template file"  1 m_flagtmplext
case_is "skill folder with no SKILL.md"    1 m_noskill
case_is "broken link in a companion doc"   1 m_badlink
case_is "a whole skill tree is missing"    1 m_notree
printf 'Legitimate content must not false-positive\n'
case_is "link with a title"                0 m_titled
case_is "link with an anchor"              0 m_anchor
case_is "wikilink inside a fence"          0 m_fencelink
case_is "link inside an inline code span"  0 m_codespan
case_is "nested fences"                    0 m_nested
case_is "link inside templates/"           0 m_template

m_regexlink() { printf '\nSee [[al.ha]].\n' >> "$1/skills/alpha/SKILL.md"; }
m_unbalanced(){ printf '\n%s%s%s\nSee [[definitely-not-a-skill]] and [x](nope.md).\n' "$bt" "$bt" "$bt" >> "$1/skills/alpha/companion.md"; }
m_aliasbad()  { printf '\nSee [[no-such-skill|display text]].\n' >> "$1/skills/alpha/SKILL.md"; }
m_aliasok()   { printf '\nSee [[beta|the beta skill]].\n' >> "$1/skills/alpha/SKILL.md"; }
m_dblspan()   { printf '\nWrite %s%s[[no-such-skill]]%s%s to show a literal link.\n' "$bt" "$bt" "$bt" "$bt" >> "$1/skills/alpha/companion.md"; }
m_tilde()     { printf '\n~~~markdown\nSee [[no-such-thing]].\n~~~\n' >> "$1/skills/alpha/companion.md"; }
m_rootrel()   { printf '\nSee [x](/skills/beta/SKILL.md).\n' >> "$1/skills/alpha/companion.md"; }
m_miscasefil(){ printf '\nSee [x](SKILL.MD).\n' >> "$1/skills/alpha/companion.md"; }
m_sentinel()  { printf 'x' > "$1/.lint-fail"; }

printf 'Regressions from the second review pass\n'
case_is "wikilink with a regex metachar"   1 m_regexlink
case_is "unbalanced code fence"            1 m_unbalanced
case_is "aliased link to a missing skill"  1 m_aliasbad
case_is "mis-cased file link"              1 m_miscasefil
case_is "aliased link to a real skill"     0 m_aliasok
case_is "double-backtick code span"        0 m_dblspan
case_is "tilde fence"                      0 m_tilde
case_is "root-relative link"               0 m_rootrel
case_is "stale .lint-fail in the repo"     0 m_sentinel


# --- check 5: universal-conventions copies ---
# Why two copies: AGENTS.md § "Where the same prose must exist in two files". These cases pin the
# five states the check must tell apart. The bare fixture has neither file, which is itself one of
# the five.
UNIV_REL=skills/new-project/templates/CONVENTIONS-universal.md
mk_rule_block() { # $1 = file, $2 = body line
  printf -- '<!-- comment-rule:start -->\n### Comments\n\n%s\n<!-- comment-rule:end -->\n' "$2" >> "$1"
}
mk_new_project() { # the template lives inside a skill, so that skill must be valid or check 1 fires
  mkdir -p "$1/skills/new-project/templates"
  printf -- '---
name: new-project
description: d
---

Scaffolder.
' > "$1/skills/new-project/SKILL.md"
}
u_pair()        { mk_new_project "$1"
                  mk_rule_block "$1/$UNIV_REL" 'Write the comment the code cannot carry.'
                  printf -- '# guide\n\n## Conventions\n\n' > "$1/AGENTS.md"
                  mk_rule_block "$1/AGENTS.md" 'Write the comment the code cannot carry.'; }
u_drifted()     { u_pair "$1"
                  # One word. The whole point of the check is that this is not a stylistic variance.
                  sed -i 's/cannot carry\./cannot carry, and nothing else./' "$1/AGENTS.md"; }
u_no_agents()   { mk_new_project "$1"
                  mk_rule_block "$1/$UNIV_REL" 'Write the comment the code cannot carry.'; }
u_no_template() { printf -- '# guide\n\n## Conventions\n\n' > "$1/AGENTS.md"
                  mk_rule_block "$1/AGENTS.md" 'Write the comment the code cannot carry.'; }

case_is   "identical rule blocks pass"              0 u_pair
case_is   "one word of drift fails"                 1 u_drifted
case_is   "template has the block, AGENTS.md does not" 1 u_no_agents
case_is   "AGENTS.md has the block, template does not" 1 u_no_template
# Naming the missing side is the point (AGENTS.md § "Where the same prose must exist in two files").
case_fails_saying "missing AGENTS.md side is named"    u_no_agents   "AGENTS.md does not"
case_fails_saying "missing template side is named"     u_no_template "consumers would receive nothing"
case_fails_saying "drift names both files"             u_drifted     "differs between AGENTS.md"
# A repo with neither file must pass — but VISIBLY, so assert the message, not only the exit code
# (the vacuous pass `case_silent` guards against).
case_says "no pair present says so rather than passing in silence" m_noop "nothing to compare"
# A file that DOCUMENTS the convention mentions the marker in prose above the block it describes.
# Matching the marker as a substring starts the capture there and reports two identical copies as
# differing.
u_prose_mention() { u_pair "$1"
                    printf -- 'Prose about `%s` and `%s` markers, above the block.

'                       '<!-- comment-rule:start -->' '<!-- comment-rule:end -->' > "$1/tmp.md"
                    cat "$1/AGENTS.md" >> "$1/tmp.md"; mv "$1/tmp.md" "$1/AGENTS.md"; }
case_is   "prose mentioning the marker is not mistaken for the block" 0 u_prose_mention

# --- check 6: install roots (advisory) ---
r_absent()  { :; }                                    # roots/ is never created
r_empty()   { mkdir -p "$1/roots/claude" "$1/roots/pi"; }
r_partial() { mkdir -p "$1/roots/claude" "$1/roots/pi"
              # alpha linked, beta NOT — a partially-linked root is what exercises per-skill naming.
              # A wholly empty root collapses to one summary line by design (see r_empty).
              mk_link "$1/roots/claude/alpha" "$1/skills/alpha"; }
r_linked()  { mkdir -p "$1/roots/claude" "$1/roots/pi"
              # Claude root gets skills/* ONLY; the pi root gets skills/* AND skills-pi/*.
              # Both roots end up genuinely in sync, so ANY complaint about gamma is the
              # asymmetry bug rather than a true finding about the other root.
              mk_link "$1/roots/claude/alpha" "$1/skills/alpha"
              mk_link "$1/roots/claude/beta"  "$1/skills/beta"
              mk_link "$1/roots/pi/alpha"     "$1/skills/alpha"
              mk_link "$1/roots/pi/beta"      "$1/skills/beta"
              mk_link "$1/roots/pi/gamma"     "$1/skills-pi/gamma"; }
r_stale()   { mkdir -p "$1/roots/claude" "$1/roots/pi" "$1/skills/ghost"
              printf -- '---\nname: ghost\ndescription: d\n---\n\nGhost.\n' > "$1/skills/ghost/SKILL.md"
              mk_link "$1/roots/claude/ghost" "$1/skills/ghost"
              rm -rf "$1/skills/ghost"; }
r_shadow()  { mkdir -p "$1/roots/claude" "$1/roots/pi"
              # The defect TASK-037 names: a skills-pi/ stub junctioned into the CLAUDE root. Its
              # source exists, so the staleness half passes it; it is missing from nowhere, so the
              # missing half passes it too. Only a tree-membership test sees it.
              #
              # The pi root is linked correctly on purpose. Leave it empty and it legitimately prints
              # "nothing is linked into it" for its OWN reasons, which would make the companion
              # assertion below pass or fail for the wrong root.
              mk_link "$1/roots/pi/alpha" "$1/skills/alpha"
              mk_link "$1/roots/pi/beta"  "$1/skills/beta"
              mk_link "$1/roots/pi/gamma" "$1/skills-pi/gamma"
              mk_link "$1/roots/claude/gamma" "$1/skills-pi/gamma"; }
r_nested()  { mkdir -p "$1/roots/claude" "$1/roots/pi" "$1/wt/case/skills/alpha" "$1/wt/case/skills/beta"
              # The fixture dir is $WORK/case, so `case` is the repo name — and this layout repeats it
              # as an ancestor, the way a worktree at <repo>/wt/<repo> or a clone at ~/src/<r>/<r> does.
              # Shortest-prefix removal takes the FIRST `case/` and derives tree `wt`, which is in no
              # root's tree list, so every link here gets reported as a shadow. Longest-prefix derives
              # `skills` and the root is correctly in sync.
              mk_link "$1/roots/claude/alpha" "$1/wt/case/skills/alpha"
              mk_link "$1/roots/claude/beta"  "$1/wt/case/skills/beta"; }
r_foreign() { mkdir -p "$1/roots/claude" "$1/roots/pi" "$WORK/other-repo/skills/foreign"
              mk_link "$1/roots/claude/foreign" "$WORK/other-repo/skills/foreign"
              rm -rf "$WORK/other-repo/skills/foreign"; }   # dangling, but not ours

printf 'Install-root drift (advisory — asserted on output; exit must stay 0)\n'
case_says   "absent root is stated, not silent"   r_absent  "skipped"
case_says   "empty root collapses to one line"     r_empty   "exists but nothing is linked into it"
case_says   "one drifted skill is named"          r_partial "beta is not linked into"
case_says   "junction whose source is gone"       r_stale   "stale junction"
case_silent "a link into another repo is ignored" r_foreign "stale junction"
case_silent "skills-pi absent from claude root"   r_linked  "gamma is not linked into"
case_says   "skills-pi shadowing the claude root" r_shadow  "never linked into this root"
# The false-positive direction, as a POSITIVE assertion (see `case_silent`): `roots/pi is in sync`
# can only print if the loop ran AND cleared every legitimate skills-pi link in the pi root — which
# is the whole real-world install.
case_says   "legit skills-pi link in the pi root"  r_linked  "roots/pi is in sync"
# A root holding only a shadow is not an empty root; the two advisories must not contradict.
case_silent "shadow root is not called empty"      r_shadow  "nothing is linked into it"
# A root holding ONLY shadows still collapses to one line — gating the collapse on shadow==0 printed
# one advisory per skill instead, the wall of text the collapse was measured to remove.
case_says   "shadow-only root collapses, precisely"  r_shadow  "only shadow junctions"
# The repo name repeating as an ancestor component must not turn every in-repo link into a shadow.
case_says   "repo name repeated in the target path" r_nested  "roots/claude is in sync"

printf '\nskills-lint-test: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
