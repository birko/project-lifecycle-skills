---
id: STORY-019
parent: EPIC-004
# status — one of: planned, in-progress, done, cancelled
status: done
created: 2026-09-18
---

# `review-comments` — find comments that belong elsewhere, and move them there

## User story

As a developer with an existing codebase, I want a command that finds comments belonging somewhere
else and fixes them, so that the rule reaches code nobody is currently touching — which is where
the worst of it is.

## Behaviour

- Runs over **the work in hand by default** (the current diff), and over the **whole repository**
  with `--all`. Both were asked for explicitly; neither is the only mode.
- Reports each finding with the destination that caught it — code / version history / the ticket /
  a decision record — so the verdict is checkable rather than asserted.
- Applies fixes on confirmation.
- **Never destroys the only record of something.** A comment that fails the test but is the sole
  place its content exists is relocated first — filed as a task, written into a decision record or
  a `docs/` file — and the source keeps a one-line pointer. It asks before filing anything.
- `/tasks close` invokes it as **its own axis**, reported beside standards, fidelity and
  correctness, never merged into one ranked list.

**The failure mode that matters is asymmetric.** Removing too little costs a messy file; removing
too much destroys reasoning nobody wrote down twice, and it is unrecoverable in practice because
finding it again means knowing it existed. Every test for this story therefore includes comments
that **must survive**, not only comments that must go.
