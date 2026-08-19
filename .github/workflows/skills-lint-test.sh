#!/usr/bin/env bash
# skills-lint-test — regression tests for skills-lint.sh.
#
# The lint is the repo's only automated gate, so a silent regression in it disables the gate
# without any signal. Each case below builds a throwaway fixture, mutates one thing, and asserts
# the lint's exit code. A review of the first version found eight defects; every one has a case here.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
LINT="$(pwd)/.github/workflows/skills-lint.sh"

WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0

# Check 4 (install roots) reads $HOME by default. Point it at nothing so every case below is
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
  # MSYS `ln -s` silently COPIES unless winsymlinks is set, and the repo's Windows installer creates
  # junctions anyway — so fall back to exactly what install.ps1 makes.
  rm -rf "$1"
  command -v cygpath >/dev/null 2>&1 || return 1
  powershell -NoProfile -Command "New-Item -ItemType Junction -Path '$(cygpath -w "$1")' -Target '$(cygpath -w "$2")' | Out-Null" >/dev/null 2>&1
  [ -L "$1" ]
}

# Check 4 is advisory and never touches the exit code, so `case_is` cannot see it at all. These
# assert on OUTPUT and still require exit 0 — an advisory that began failing the build would itself
# be a regression.
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
  # Require the check to have RUN. A bare "must not contain" passes trivially when check 4 is absent
  # altogether, which is the vacuous pass this repo has already been bitten by once — so these guards
  # would have had power only against a buggy check, never against a deleted one.
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF -- '== 4. install roots' && ! printf '%s' "$out" | grep -qF -- "$pat"; then
    printf '  ok    %s\n' "$name"; pass=$((pass+1))
  else
    printf '  FAIL  %s (exit %s; wanted check 4 to run and output NOT to contain: %s)\n' "$name" "$rc" "$pat"; fail=$((fail+1))
  fi
}

m_noop()      { :; }
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

# --- check 4: install roots (advisory) ---
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
              rm -rf "$1/skills/ghost"; }              # link now dangles; source gone
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

printf '\nskills-lint-test: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
