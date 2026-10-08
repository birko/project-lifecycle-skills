---
id: FEATURE-004
created: 2026-10-08
owner: František Bereň
# status — one of: idea, review (built, sign-off pending), done, dropped, superseded
status: idea
---

# Specs learn from OpenSpec — reviewable regen diffs, checked spec files, and a watch on upstream

> Stakeholder-readable. A project manager or end user should understand the problem and the proposed shape without reading any code.

## Problem

Our specs describe what each skill actually does. Every time a fix lands, the spec for that area is regenerated and
the change is reviewed: *did the behaviour change the way we meant it to?* That review is the whole point of the
specs, and today it is harder than it needs to be:

- **Requirements are long.** 131 of our 383 requirements run past 500 characters, so a reviewer reads a paragraph to
  find the one clause that changed.
- **The diff is the whole file.** A requirement that was only renamed or reworded looks like a large change.
- **A lost example goes unnoticed.** If a regeneration drops one of a requirement's worked examples, nothing points at it.
- **Nothing checks the spec files themselves.** A placeholder Purpose, an example with no steps, or two requirements
  whose names differ only in capital letters all pass.
- **An interrupted full regeneration saves nothing**, and a rewrite can flip a file's Windows line endings, which turns
  the review into a whole-file diff.

OpenSpec, a widely used tool in the same space, fixed these same problems between August and October 2026
(v1.8.0 to v1.14.1). We read its release notes once, by hand; nothing tells us when it learns something new.

## Proposed shape

Bring the lessons that fit our model into `/specs`, keeping our model as it is: specs are generated *from* the code,
never written ahead of it. These are the changes:

- Regeneration flags new or changed requirements that run long.
- Its review is shown one requirement at a time, with renames marked.
- It names any worked example that disappeared.
- The repo's CI check also checks the structure of the spec files.
- A full regeneration saves each area as soon as its review is accepted.
- Every rewrite keeps the file's existing line endings.

Separately, a weekly GitHub job watches OpenSpec's releases and opens one issue per new release, with its notes, so
someone can decide whether it holds anything worth adopting. It changes nothing in the repo by itself.

## Open questions distilled from the grill

| id | question | type | blocked-by | state | claimed-by |
|----|----------|------|------------|-------|------------|
| Q1 | How should regen treat requirements longer than ~500 characters? | decision | — | resolved → D1 | — |
| Q2 | Should the regen review show changes per requirement, with renames marked? | decision | — | resolved → D2 | — |
| Q3 | Should a worked example that disappears in a regen be a finding? | decision | — | resolved → D3 | — |
| Q4 | Where should the spec-file structure check live? | decision | — | resolved → D4 | — |
| Q5 | Should a full regeneration save each area as it finishes? | decision | — | resolved → D5 | — |
| Q6 | Should a rewrite keep the file's existing line endings? | decision | — | resolved → D6 | — |
| Q7 | What should happen when OpenSpec ships a new release? | decision | — | resolved → D7 | — |
| Q8 | Does `/specs verify` ever report a check it could not run as passing? | fact | — | resolved → D8 | — |
| Q9 | Does the watcher's issue get a label or an owner, so it is not lost among other issues? | decision | Q7 | resolved → D10 | — |

**Fog** — concerns not yet precise enough to state as a question:

- OpenSpec's newer validation also checks archived changes for unfinished work. We have no "archive", so it is not
  yet clear whether anything in that idea maps onto closed tasks.

## Out of scope (initial)

- Adopting OpenSpec itself, or its proposal-first flow, in which changes are written as additions, edits and removals
  before the code. Our specs are harvested from the code by design.
- Splitting all 131 existing long requirements in one pass. Each one is split when it next changes.

## Prototype

Skipped — the change is to how a skill reviews and writes text files. Running `/specs regen` on a real area is the
proof, and each task's drill is where that happens.
