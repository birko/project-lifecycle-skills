---
id: TASK-122
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-09
depends-on: []
blocks: [TASK-123]
findings: []
pr: null
github-issue: null
jira-key: null
---

# The slicing doctrine — what "atomic and independently completable" actually means

## Context

`decompose` and `plan` today say a task should be *"atomic and independently completable"* and stop
there. That is a property to check, not a method to follow, so the actual slicing is improvised every
time — and the failure it produces is specific: **tasks that cannot land green on their own.**

The doctrine, from the story:

- **Vertical, not horizontal.** Each slice cuts a narrow but complete path through every layer — not a
  slice of one layer across the whole feature.
- **Demoable or verifiable alone.** A completed slice can be shown or checked without its siblings.
- **Sized to one fresh context window.** Not "small"; a stated, checkable bound.
- **Prefactoring goes first** — make the change easy, then make the easy change.

### The design question this task must settle, not assume

**Where the doctrine lives.** Two verbs consume it — `/tasks plan` and `/feature decompose` — and this
repo's rule is that a vocabulary shared by several skills has **one owning file, and the owner is
wherever it already lives**. Nothing owns slicing today, so this task picks the owner and the others
point at it. Expanding an existing home beats minting a neutral one; a partial copy is worse than
either, because it diverges like a full copy while being silently narrower.

**"One fresh context window" needs an operational reading.** As written it is a metaphor. A slicer needs
to know what to actually check — files touched, layers crossed, whether the task's own Context can be
read without opening anything else. Left as prose it becomes taste, and taste is what the doctrine
exists to replace.

## Acceptance criteria

- [ ] The four rules are written where a slicer will read them, in one owning file, with the owner chosen
      and the reason recorded
- [ ] `/tasks plan` and `/feature decompose` both reach the doctrine — by pointer, never by copy
- [ ] **Vertical vs horizontal** is illustrated with a worked pair on this repo's own material: one
      slice that lands green alone and one that cannot, so the distinction is demonstrated rather than
      asserted
- [ ] "Sized to one fresh context window" has an operational test a slicer can apply
- [ ] Prefactoring is stated as an ordering rule — the prefactor is its own slice, before the change it
      enables, not folded into it
- [ ] The doctrine says what to do when a change **cannot** be sliced vertically, and points at
      TASK-123 rather than leaving the case open
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Wide refactors** — TASK-123, the explicit exception, which depends on this rule existing.
- **`/feature prototype`'s fourth form** — TASK-124, the story's other half.
- Changing what `plan` or `decompose` otherwise do.

## Human test plan

- [ ] Give a cold runner — per [[populate-tests]] § *Acquiring a cold runner* — a real undecomposed
      story from this repo and the doctrine, and have it slice. Expected: it produces vertical slices and
      says which rule rejected any slice it discarded. Withhold both from its brief.
