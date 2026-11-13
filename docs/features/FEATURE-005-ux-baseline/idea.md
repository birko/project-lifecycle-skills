---
id: FEATURE-005
created: 2026-11-13
owner: František Bereň
# status — one of: idea, review (built, sign-off pending), done, dropped, superseded
status: done
---

# UX baseline for UI review and prototypes

> Stakeholder-readable. A project manager or end user should understand the problem and the proposed shape without reading any code.

## Problem

When a project's own rulebook says nothing about how its interface should behave, nothing checks it. A consumer
project (Birko.Web / Symbio) put a confirm dialog in front of every action, including ones that could simply be
undone, because no review ever asked whether a confirmation was needed. The people who feel it are the end users
clicking through dialogs, and the cost of doing nothing is that every project re-learns the same interaction
mistakes on its own.

## Proposed shape

A short list of interaction-design judgement calls (a "UX baseline") that the review and prototype tools check
user-interface work against, when the project has no rule of its own. A change the baseline questions gets a
labelled, non-blocking note, never a hard failure, and any rule the project wrote down always wins over the
baseline.

**Recorded after the fact.** The work shipped as TASK-293 on 2026-10-11, under EPIC-010, before it had a feature.
This folder was created on 2026-11-13 so the stakeholder tree records it.

## Open questions distilled from the grill

No grill was run: the questions were settled when TASK-293 was planned and closed, and each became a row in
[decisions.md](decisions.md).

| id | question | type | blocked-by | state | claimed-by |
|----|----------|------|------------|-------|------------|
| Q1 | Where does the baseline live, and who owns it? | decision | — | resolved → D1 | — |
| Q2 | Does a baseline finding block a review? | decision | — | resolved → D2 | — |
| Q3 | Do prototypes use it too? | decision | — | resolved → D3 | — |
| Q4 | Should every new project be asked its confirm-versus-undo policy? | decision | — | resolved → D4 | — |

## Out of scope (initial)

- Any one consumer's UI framework or rules: those belong to the consumer.

## Prototype

Skipped — the work shipped before this feature was recorded, and the baseline file itself is the artifact.
