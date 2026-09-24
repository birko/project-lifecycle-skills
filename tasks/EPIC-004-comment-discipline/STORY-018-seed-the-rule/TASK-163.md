---
id: TASK-163
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-24
depends-on: []
blocks: []
findings: [DRILL-162-1]
pr: null
github-issue: null
jira-key: null
---

# Comment findings the TASK-162 drill surfaced outside its nine

## Context

Found while doing **TASK-162**, by its human test plan: two cold `claude -p --disable-slash-commands`
readers on the whole guide minus the measurement table, over all six scripts. Both confirmed cold (no
skills available). Their reports reached past TASK-162's nine; these five were verified against the tree
on 2026-09-24 and are owned by no existing task.

| Site | Finding | Reader | Verified |
|---|---|---|---|
| `skills-lint-test.sh:313` | *"they differ" sends a reader to diff two files, one of which is empty* — near-verbatim `AGENTS.md` § *Universal prose* (*"because "they differ" sends a reader to diff two files one of which is empty"*) | both | ✅ |
| `skills-lint-test.sh:320-322` | the pin (substring match reports identical copies as differing) earns its place; *"which is what happened the moment this convention was written into AGENTS.md"* is version history | B | ✅ |
| `skills-lint.sh:144-147` | a pointer claiming AGENTS.md § *A format one skill reads is a contract* *"also scopes out the receiver that names a flag only to say it is UNSUPPORTED"* — the word does not appear anywhere in `AGENTS.md`. A pointer at a destination that does not hold the content | A | ✅ (`grep -i unsupported AGENTS.md` is empty) |
| `skills-lint.sh:167-170` | the marker-alone-on-its-line mechanic stays; the clause narrating *when* the substring version failed is history | B | ✅ |
| `skills-lint.sh:291-295` | narrates an earlier implementation (*"gating it on `shadow -eq 0` sent…"*); the test at `skills-lint-test.sh` (`shadow-only root collapses`) carries the same pin | A | ✅ |
| `skills-lint.sh:167-170` (also) | *"a few hundred lines above the block"* — the prose mention is `AGENTS.md:334`, the block `:371`: 37 lines | C, D | ✅ |
| `skills-lint.sh:202-203` | *"every case below unwritable"* — no case follows in this file; the cases are in `skills-lint-test.sh` | D | ✅ |
| `skills-lint.sh:118` | *"Match any `/word verb --flag`"* — the narrower form `AGENTS.md`'s check-4 bullet records as superseded; `ARG_RE` admits arguments between verb and flag | D | ✅ |

**Split, recorded rather than resolved:** `skills-lint-test.sh:313` was reported by both first-round
readers (A, B) and passed by both re-run readers (C, D — D lists `313` among its passes). Take it with
the rest, but it is the weakest row.

**The `:144-147` one is not like the others.** The rest are restatements; this is a pointer that sends a
reader to a section that does not say what it claims. Either the scoping lives somewhere else (find it,
repoint) or it was never written (then the comment is the only copy — relocate before cutting).

## Acceptance criteria

- [ ] Each row of the table is acted on or dismissed with a reason recorded.
- [ ] `:144-147` resolves one of two ways, stated: repointed at wherever the UNSUPPORTED scoping actually lives, or — if it lives nowhere — the content is relocated to the guide first and the comment becomes a pointer. Never cut as a dangling pointer.
- [ ] Every deletion names the destination that holds the content, verified by reading it.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, case count unchanged.

## Out of scope

- The evidence/QA-log blocks at `skills-lint-test.sh:134-180` — **TASK-153**, which already names the neighbouring blocks.
- `skills-lint.sh:219`'s wrong check number — **TASK-081**.
- The `ARG_RE` block — **TASK-141**.
- The `pi-install` headers — **TASK-141**.
- `AGENTS.md` saying "check 5" for install-root drift and 47 cases — **TASK-081** / **TASK-029**.

## Human test plan

- [ ] Two cold readers on the same fixture shape as TASK-162's (whole guide minus the measurement table, all six scripts). Expected: these five not reported; nothing TASK-162 cleared comes back.

## Implementation plan

_Populated by `/tasks plan TASK-163` — leave empty until then._
