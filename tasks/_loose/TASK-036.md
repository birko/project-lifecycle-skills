---
id: TASK-036
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: [CR-020-4]
pr: null
github-issue: null
jira-key: null
---

# `/specs regen`'s state gate can read the commented enum instead of the status

## Context

`/code-review` finding from TASK-020's close gate (2026-08-19), in a file that task's diff did not
touch.

**Severity corrected 2026-08-19, before any work started.** Filed P1 on the reviewer's framing; a
first-hand read of `regen.md` downgrades it to **P2**. The file *does* already say *"Read the YAML
**value**, not the line"*, and a correct YAML read never sees a comment line at all. The reviewer's
"blast radius is total" rested on an `grep 'status:' | head -1` implementation that **nothing in the
file prescribes**. What survives is real but narrower: the instruction's only worked example is the
*trailing* comment, so an implementer working from the surrounding shell-heavy prose gets no warning
about the leading one.

`skills/specs/verbs/regen.md:52` warns the reader about a **trailing** comment on the status line
(`status: done  # merged 5414637e`). It says nothing about the **leading** one that every
template-generated task carries: `skills/tasks/templates/task.md` emits

```
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
```

An unanchored first-match read — `grep 'status:' <file> | head -1` — returns the **comment**, whose
first token parses as `todo`. An implementer who does that concludes the work never landed and refuses
the commit's inferred evidence for every template-generated task, `done` ones included, in the
dangerous direction: `shaped-by-unresolved` climbs while `shaped-by-derived:` still reads `true`, so
[[roadmap]]'s DV8 and DV11 read a generator gap as a project gap, and nothing errors.

**That is a reachable mistake, not a mandated one** — which is exactly why the fix is worth doing and
why it is P2 rather than P1. Every task file in this repo and in any repo scaffolded from the template
carries the comment line, so the trap is always armed; it just needs someone to write the naive grep.
Whether it has already been written anywhere is the first thing to check.

## Acceptance criteria

- [ ] `regen.md` names the commented enum line explicitly as the thing to skip, not only the trailing comment
- [ ] The instruction anchors the read (`^status:`) rather than describing the intent and leaving the pattern to the reader
- [ ] Verified against a real task file carrying the template's comment line — the read returns `done`, not `todo`
- [ ] Checked whether any *existing* implementation or prose in `skills/` actually does the naive first-match read; if none does, the task records that the trap was armed but unsprung
- [ ] The trailing-comment case still works (`status: done  # merged abc1234` → `done`)
- [ ] A spot-check says whether `shaped-by-unresolved` counts already recorded in this repo or Symbio were inflated by this, so DV8/DV11 readings are not trusted blindly afterwards
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Re-deriving provenance across every area to correct historical counts — decide that once the read is fixed and the inflation is measured; it may warrant its own task.
- DV11's own reporting rules in [[roadmap]] — they are correct; they were being fed a bad number.
- The commented enum line in the template itself. It is useful documentation and should stay; the reader must cope.

## Human test plan

N/A — every criterion is a text read against a real file, asserted mechanically. A human eyeballing the
same grep adds nothing.
