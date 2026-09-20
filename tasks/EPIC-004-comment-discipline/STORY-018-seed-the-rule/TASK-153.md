---
id: TASK-153
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-151-1]
pr: null
github-issue: null
jira-key: null
---

# The 8-of-39 measurement has a fifth copy, in the test that pins it

## Context

Found while doing **TASK-151**, whose criterion 4 required walking every comment block in this repo's
six scripts and asking the rule's actual question — *delete the line, then search for where its
content already lives*. TASK-151's own table named four copies of the check-4 measurement; the walk
found a fifth it did not know about.

`.github/workflows/skills-lint-test.sh:137-140`:

> `# An ARGUMENT between the verb and its flag. The check matched only `/skill verb --flag`, so every`
> `# invocation carrying an id, a placeholder or a subcommand first was invisible — measured at 8 of 39`
> `# real invocations (~20%) on this repo, including `/tasks move <ids> --to`, added by the same epic`
> `# that wrote this suite. These two are EVIDENCE, not pins: the first passes against the old lint.`

**Destination: the ticket.** TASK-108 carries the same measurement at `:39`, `:114` and `:172`, and
`AGENTS.md:279` carries it again. TASK-151 reduced the sixth copy — `skills-lint.sh:124-128` — to a
pointer at TASK-108; this one was left because it sits outside TASK-151's four named sites and taking
it would have widened an in-flight task.

**Why this is genuinely borderline, and must not be swept without thought.** The comment rule
explicitly protects *"a test comment naming the finding it pins and the mechanism it proves"* — so a
comment here **should** name its finding. The question is only whether *naming* it requires
reproducing the number, or whether `TASK-108`'s id does the naming. The sentence that must survive
either way is the last one: **these two cases are EVIDENCE, not contract pins** — the first passes
against the old lint — and that distinction lives nowhere else in the file.

`:157-160` and `:182-186` are the neighbouring blocks and make the same evidence/pin distinction
without quoting a measurement; they are the shape this one should probably take.

## Acceptance criteria

- [ ] `skills-lint-test.sh:137-140` either points at TASK-108 for the measurement, or keeps it with a recorded reason. "Left as is" alone does not close this.
- [ ] Whichever way it goes, the EVIDENCE-not-pin distinction survives in full — it is the half that lives nowhere else.
- [ ] The three blocks at `:137-140`, `:157-160` and `:182-186` end up consistent with each other about how much of a finding a test comment restates. A fix to one that leaves the other two in a different style is a half-fix.
- [ ] `AGENTS.md` § Comments' verdict row for `skills-lint-test.sh` is updated to match the outcome.
- [ ] `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh` both pass.

## Out of scope

- The other four copies — TASK-108 and `AGENTS.md:279` own those, and TASK-151 already reduced `skills-lint.sh`'s.
- `pi-install.sh` / `install.sh` and their ADR-overlapping why-clause — **TASK-148** owns that.
- The comment rule's wording — settled, FEATURE-002 D1/D2.

## Human test plan

- [ ] Run `/review-comments --all` and confirm this site is no longer reported, or is reported and the recorded reason explains why it stands.
- [ ] Read `:137-140`, `:157-160` and `:182-186` in sequence. Expected: a reader cannot tell which of the three was edited — they answer "why does this case exist" the same way.

## Implementation plan

_Populated by `/tasks plan TASK-153` — leave empty until then._
