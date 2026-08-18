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

printf '\nskills-lint-test: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
