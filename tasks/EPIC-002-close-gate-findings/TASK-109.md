---
id: TASK-109
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-3, CR-5]
pr: null
github-issue: null
jira-key: null
---

# Two templates ship a live value their own rules say must be chosen, so a faithful render mints it

## Context

**From a [[code-review]] pass on 2026-09-08.** Two findings, filed as one task because they are one
root cause: **a template ships a live value for a field the surrounding rules say must be *declared* or
*derived*, so an agent rendering the template faithfully creates the very state the rules forbid.**
Filed at epic level because the fix spans two skills and neither owns it alone.

### CR-3 — `skills/specs/templates/map.yml:20`

The template hard-codes `coverage: verified` beside `tracked-files-at-scan: 0` — a combination
`init.md` step 4's own verdict table declares **impossible**, since `verified` requires a non-empty scan
set. Step 6 says *"No `.map.yml` on disk → render `templates/map.yml`"*, so any render that does not
overwrite these keys ships exactly the *"map that looks populated and blessed while nothing checked
it"* state the `coverage` key was added to prevent.

**Unlike `example-capability`, `verified` does not look like a placeholder** — which is what makes it
survive review. A reader scanning the rendered file sees a plausible verdict, not an obvious stub.

### CR-5 — `skills/tasks/templates/config.yml:12`

The comment directly above it says `/tasks init` *"only writes it once someone has actually chosen"*
and that *"the line ABSENT … means undeclared"* — while the template ships `integration: pr-per-task`
as a live line. `init.md` step 3's Absent branch says *"write it from the template"*, so a faithful
render **mints a declaration nobody made.**

This is precisely the DRILL-053-6 defect — `integration: pr-per-task` in a repo with no git — that the
surrounding prose was written to kill. The prose landed; the template it points at did not change, so
the defect is reachable by following the instructions correctly.

### Why one task

Both are the same failure with the same shape and the same fix-shape: **make the template's value
absent or unambiguously a token, so that rendering cannot assert what only a run can determine.** Fixed
separately, the second one is likely to be fixed differently — and the principle is what needs to hold.

## Acceptance criteria

- [ ] `templates/map.yml` cannot render a map claiming a coverage verdict nothing computed — the value
      is absent, `unverified`, or a `{{TOKEN}}` the renderer must fill
- [ ] `templates/config.yml` cannot render an `integration:` declaration nobody chose — the line is
      commented out or tokenised, so **absent** means undeclared exactly as its own comment promises
- [ ] Each template agrees with the prose that points at it; where the two disagreed, the fix names
      which one was wrong rather than quietly changing both
- [ ] The rule behind both is recorded once, where it belongs — a template must not ship a live value
      for a field its own skill says is declared or derived
- [ ] A faithful render of each template is exercised and inspected, not reasoned about
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Re-litigating `integration:` as a declaration rather than a derivation** — settled by TASK-021 and
  TASK-023; this task fixes the template that undercuts them.
- Changing what `coverage:` means or how many keys the contract has — TASK-033 and TASK-079 own that.
- Auditing every other template for the same shape. If the rule is worth stating, that sweep is its own
  task; say so rather than widening this one.

## Human test plan

- [ ] Render each template into a throwaway repo exactly as its skill instructs, with no manual
      correction. Expected: the resulting `.map.yml` claims no coverage verdict, and the resulting
      `.config.yml` has no `integration:` declaration. Both currently arrive populated.
