---
id: TASK-143
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-142]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The only-copy rule — relocate before deleting, never destroy the last record

## Context

Implements FEATURE-002 **D9**, and it is the riskiest behaviour in the epic.

When the command finds a comment that fails the test but whose content exists **nowhere else**, it
must not simply delete it. It files it where it belongs — a task for a finding, a decision record
or a `docs/` file for a rationale — and leaves a one-line pointer in the source. It asks before
creating anything.

**Why this is not over-caution.** The alternative argument is that git keeps the old version, so
nothing is truly lost. That is true and useless: recovering a deleted comment means knowing it
existed and which file it was in, which is exactly the knowledge the comment was carrying. A
deletion here is unrecoverable in practice even though it is recoverable in theory.

The judgement — *is this the only copy?* — is the hard part and it cannot be answered by looking at
the comment alone. It needs a search for the content elsewhere in the repo: an open task, a
decision record, a `docs/` page. A run that assumes "only copy" without looking will file
duplicate tickets for things already tracked; a run that assumes "surely it's written down
somewhere" will delete the thing this task exists to protect. Bias toward the second question being
answered by evidence, not by plausibility — the same standard the rest of this repo applies to
declarations.

On `--all`, this can want to file a lot of tickets at once. Decide and document what it does about
that; asking once per finding across three hundred findings is not a usable answer.

## Acceptance criteria

- [x] A comment failing the test whose content is found elsewhere in the repo is deleted, and the report names where the content already lives.
- [x] A comment failing the test whose content is found **nowhere** is never deleted in the same step as its relocation being proposed.
- [x] Relocation targets are chosen by kind: a finding becomes a task, a rationale becomes a decision record or `docs/` file.
- [x] Nothing is created without asking. The question put is written out in the skill file, in the words it is actually asked.
- [x] The answer-less path is defined and does not invent a decision: no answer means the comment stays and the finding is reported unresolved — never a silent delete, and never a silent skip that reads like a pass.
- [x] After relocation the source carries a one-line pointer to where the content went.
- [x] `--all` states how it handles many only-copy findings at once.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The check itself and its scopes — TASK-142.
- `/tasks close` wiring — TASK-144.

## Human test plan

Cold drill, acquired as in TASK-140.

**The fixture is the test.** Build a small repo containing: (a) a comment describing a bug that
already has an open task, (b) a comment describing a bug that has no task anywhere, (c) a rationale
comment whose reasoning is already in an ADR, (d) a rationale comment whose reasoning exists
nowhere else.

- [x] Run the command over it. Expected: (a) and (c) deleted with the existing task/ADR named in the report; (b) and (d) held, with a relocation proposed and a question asked before anything is created.
- [x] Answer nothing. Expected: (b) and (d) are still in the source, and the report says they are unresolved. Expected failure: they were deleted, or they were skipped silently in a way that reads like they passed.
- [x] Confirm the relocation for (b). Expected: a task exists carrying the comment's content, and the source line points at it by id.
- [x] Expected failure mode to watch for: it files a duplicate task for (a). That means it proposed relocation without searching for the content first, and on a real repo it would bury the backlog.

### Drill record — 2026-09-19, **PASS** (3 of 4 fixture cases valid; the fourth was my error)

**Runner acquisition.** `claude -p` (CLI 2.1.276, `--permission-mode acceptEdits`, `--add-dir` for the
skills link and its junction target). Fixture at `scratchpad/drill-143`: a TypeScript repo carrying the
rule at rung 0, an open `TASK-007`, an `ADR 0003`, and four comment blocks added as an **unstaged diff**.
Brief withheld every verdict: *"Use the review-comments skill on this repo and give me its report."*

**No-answer run** — `claude -p` cannot receive an answer, so this exercises the answer-less path by
construction rather than by asking the runner to pretend.

| Fixture case | Required | Result |
|---|---|---|
| (a) defect note, `TASK-007` exists | delete, name the task | ⚠ — *"Verified not an only copy: `TASK-007` … carries the same sentence nearly word for word"* |
| (c) rationale, `ADR 0003` exists | delete, name the record | 🛑 — *"carries all three parts — the interleaving under load, one writer + enqueue, the accepted throughput bound"* |
| (b) defect note, no task anywhere | held, question asked, nothing created | **held — only copy**, question put verbatim, nothing edited |
| (d) rationale existing nowhere | *expected held* | **left alone as compliant** — see below |
| the expected failure: a duplicate task for (a) | must not occur | did not occur |

**Case (d) was miscategorised in the test plan, and the runner's handling exposed it.** The plan called
for *"a rationale comment whose reasoning exists nowhere else"* and expected a relocation. But the rule
says destination **nowhere → keep it, at whatever length it takes**, so such a comment *passes*; it is
not a finding at all. The runner drew the line exactly where D2 draws it: *"'nobody has written it down'
is not **nowhere** under this rule: it means the destination is **empty**, not absent."* A genuine
only-copy case needs a comment that **fails** the test with an **empty** destination — which is (b).
Case (d) therefore tested the compliant-survivor path instead, and passed it. The fixture had three
valid cases for this rule, not four; recorded rather than quietly rescored.

**Confirmation run** — brief: *"yes, file it as a task and leave a pointer. Apply the other deletions
with pointer lines too."*

- `tasks/_loose/TASK-008-retry-counter-never-resets.md` created, carrying the comment's content as
  Context plus an acceptance criterion the comment did not have.
- The source now reads `// Counter never resets after a success: TASK-008` — **a pointer by id**, and
  likewise `// Null-sku rows dropped instead of rejected: TASK-007` and
  `// Rationale: docs/adr/0003-single-writer-for-the-ledger.md`.
- `TASK-007` was **not** re-filed.
- The compliant debounce comment is **untouched, all four lines** — the discrimination survived the
  edit pass, not only the report pass.

**What is NOT evidenced.** `--all`'s suppression of the only-copy question (AC7) is written but never
run: the drill reached the question through the diff scope only. That is not an accident of this drill —
it is the gap TASK-152 records, since a path-scoped run is the natural way to reach it and `PATH` turned
out to be undefined. So AC7 rests on the design, not on a measurement.

**Filed from this drill: TASK-152** — the invocation block promises a `PATH` argument that the file never
defines, which is the same defect the skill refuses by name for `--batch`.

## Implementation plan

**Skipped deliberately.** The eight acceptance criteria fixed the shape completely, and the one open design question — what `--all` does with many only-copy findings — was answered by TASK-142's existing decision that `--all` asks nothing, so relocation belongs to a scoped run. No planner was spawned; recorded so the empty section is not read as a skipped gate.
