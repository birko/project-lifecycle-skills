---
id: TASK-027
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `present, uncommitted` is blind to work that was staged but never committed

## Context

Found by `/code-review` on TASK-026's diff (2026-08-19), in a file that diff did not touch.

`skills/new-project/LAYER.md:104` probes the state with `git status --porcelain --untracked-files=all
-- <path>` and then reads the result by naming two line shapes: `??` for untracked members and ` M`
for the tracked-but-uncommitted amendment. Porcelain output is **XY**, where X is the index and Y the
worktree, so those two shapes cover *unstaged* work only. An earlier adoption pass that wrote the
layer **and staged it** — `git add` without a commit — prints `M ` for a modified file and `A ` for a
new one, matches neither pattern, and is reported plain **present**.

That is exactly the loss this state exists to catch: the next clone does not have it and the next
pass writes over it. It is also the same class of blindness TASK-018 was reopened for — that round
fixed the untracked case and the tracked-but-*unstaged* case, and stopped one column short.

The row is consumed by [[new-project]] and [[adopt-project]] both, so a fix in `LAYER.md` satisfies
the layer-parity rule by construction — but confirm neither skill restates the line shapes locally.

## Acceptance criteria

- [ ] The reading rule keys on **any non-empty porcelain output** for the path rather than on a list of line prefixes — a list of shapes is what went one column short twice
- [ ] Staged-but-uncommitted work (`M `, `A `, and the rename/copy forms) reports `present, uncommitted` and gets the offer to land it
- [ ] A deliberately git-ignored path still reports plain `present` (the existing carve-out survives)
- [ ] A directory with no repo at all still routes to the `git init` offer, not to this state
- [ ] Neither [[new-project]] nor [[adopt-project]] carries its own copy of the line shapes
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The other survey states' probes. If one of them reads porcelain the same way, spawn it separately.
- TASK-026's provenance work, which only surfaced this.

## Human test plan

- [ ] On a scratch clone: write a layer artifact, `git add` it, do not commit — run the survey and confirm `present, uncommitted` with the land offer
- [ ] Repeat with the file modified and unstaged (the case TASK-018 fixed) — confirm no regression
- [ ] Repeat with the path in `.gitignore` — confirm plain `present`
- [ ] Run it in a directory with no `.git` — confirm the `git init` offer, not this state

## Implementation plan

_Populated by `/tasks plan TASK-027` — leave empty until then._
