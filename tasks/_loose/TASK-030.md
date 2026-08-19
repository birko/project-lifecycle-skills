---
id: TASK-030
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

# `close`'s single-branch SHA backfill instructs an impossible amend

## Context

Found on 2026-08-19 while closing TASK-026 on this repo, by trying to follow the instruction.

`skills/tasks/verbs/close.md` step 7 says:

> **SHA backfill:** if `pr:` should reference this very commit, write the short SHA into the task file
> now and stage that one-line edit so it rides in the *merge* (PR-per-task) — or, on a plain
> single-branch flow, fold it into the commit by amending before anything else references it.

The PR-per-task half is sound: the SHA of the *work* commit is recorded, and the edit rides in a
separate *merge* commit. The single-branch half cannot be done. To write the SHA you must first have
the commit; amending then produces a **different** SHA, so `pr:` names a commit that no longer
exists (the pre-amend object is unreachable). There is no fixed point — a commit cannot contain its
own hash.

This repo runs `integration: single-branch`, so it is the branch of that sentence this repo always
takes. What actually works is a small follow-up commit that writes the reference, which is what
TASK-026 did.

It matters beyond tidiness now that TASK-026 has landed: `pr:` is the strong path for `/specs`
provenance and a stale or missing one drops the task to the message fallback. An instruction that
cannot be followed gets silently skipped, which is how `pr: null` became the norm on 390 of 392
tasks in the first place.

## Acceptance criteria

- [ ] The single-branch path prescribes a mechanism that terminates — a follow-up commit that records the reference, or an explicit "leave `pr:` null on this flow and rely on the subject rule", decided rather than left ambiguous
- [ ] Whichever is chosen, the reason is stated inline: the amend has no fixed point
- [ ] The PR-per-task path is untouched — it is correct as written
- [ ] If the answer is a follow-up commit, `close` says what it contains and that the task file's status flip stays in the *work* commit (the ordering rationale in step 6 must survive)
- [ ] The interaction with [[specs]] provenance is named: a task left with `pr: null` falls back to the subject rule, which is weaker but honest
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Making the backfill retroactive for tasks already closed (still out of scope, as in TASK-026).
- The PR-per-task merge mechanics.

## Human test plan

- [ ] Close a throwaway task on a `single-branch` project following the revised text verbatim, and confirm `pr:` names a commit that `git cat-file -e` resolves
- [ ] Close one on a PR-per-task project and confirm nothing changed
- [ ] Run `/specs regen` afterwards on the single-branch project and confirm the task resolves through the `pr:` path, not the fallback

## Implementation plan

_Populated by `/tasks plan TASK-030` — leave empty until then._
