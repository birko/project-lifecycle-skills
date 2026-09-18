---
id: TASK-143
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] A comment failing the test whose content is found elsewhere in the repo is deleted, and the report names where the content already lives.
- [ ] A comment failing the test whose content is found **nowhere** is never deleted in the same step as its relocation being proposed.
- [ ] Relocation targets are chosen by kind: a finding becomes a task, a rationale becomes a decision record or `docs/` file.
- [ ] Nothing is created without asking. The question put is written out in the skill file, in the words it is actually asked.
- [ ] The answer-less path is defined and does not invent a decision: no answer means the comment stays and the finding is reported unresolved — never a silent delete, and never a silent skip that reads like a pass.
- [ ] After relocation the source carries a one-line pointer to where the content went.
- [ ] `--all` states how it handles many only-copy findings at once.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The check itself and its scopes — TASK-142.
- `/tasks close` wiring — TASK-144.

## Human test plan

Cold drill, acquired as in TASK-140.

**The fixture is the test.** Build a small repo containing: (a) a comment describing a bug that
already has an open task, (b) a comment describing a bug that has no task anywhere, (c) a rationale
comment whose reasoning is already in an ADR, (d) a rationale comment whose reasoning exists
nowhere else.

- [ ] Run the command over it. Expected: (a) and (c) deleted with the existing task/ADR named in the report; (b) and (d) held, with a relocation proposed and a question asked before anything is created.
- [ ] Answer nothing. Expected: (b) and (d) are still in the source, and the report says they are unresolved. Expected failure: they were deleted, or they were skipped silently in a way that reads like they passed.
- [ ] Confirm the relocation for (b). Expected: a task exists carrying the comment's content, and the source line points at it by id.
- [ ] Expected failure mode to watch for: it files a duplicate task for (a). That means it proposed relocation without searching for the content first, and on a real repo it would bury the backlog.

## Implementation plan

_Populated by `/tasks plan TASK-143` — leave empty until then._
