---
id: EPIC-003
# status — one of: planned, in-progress, done, cancelled
status: in-progress
created: 2026-09-16
owner: František Bereň
affects: skills/
# kind: omit for a normal epic; `review-intake` marks the epic a review pass was filed into
kind: review-intake
# source: review-intake epics only — where the findings came from (report path, PR, or "security-review <date>")
source: field use of the installed skills in consumer repos, 2026-09-16 — defects found by running the skills against the Birko polyrepo family (178 sibling repos, 449 tasks filed), not by a review pass over this repo. Filed as loose tasks by the agent that hit them; re-homed and stamped by /tasks move + /tasks intake --adopt.
---

# Defects found by using the skills, not by reviewing them

## Area of concern

**Where EPIC-002's findings come from a gate reading this repo, these come from the product failing in
someone else's.** That difference is the reason this is a separate epic rather than more tasks under
EPIC-002: that epic's count is how much of the close-gate review is left, and folding field reports into
it would make that number mean two things at once.

`AGENTS.md` already names this lane — *"Field feedback re-enters the pipeline — a skill that misfires in
real use is a `tasks/` bug that ships with a regression check, not a note. `done` is never the terminus."*
This epic is where that arrives.

### What makes a field defect different from a review finding

A reviewer reads the prose and asks whether it is right. A user runs it and finds out what it does. Both
tasks here were invisible to every review pass this repo has run — and not because the passes were weak:

- **TASK-130** needs a *polyrepo* to see at all. This repo is one tree, so a rule about collecting across
  sibling repos reads as correct here and is unusable there. Measured in the field: the documented
  placement has been followed **0 times in 178 repos**.
- **TASK-131** needs someone to *hand-file* a defect and then try to drain it. Every finding this repo has
  filed came through `/tasks intake`, which writes `findings:` automatically — so the escape hatch for
  hand-filed bugs has never been exercised here, and its absence is invisible from inside.

**They compound, and the tasks say so:** a sub-repo task is unreachable by collection *and*, if hand-filed,
ineligible for the pool. Fixing either alone leaves it unreachable.

## Why these carry no `findings:` ids

Deliberate, and it is the subject of one of the tasks. **TASK-131 is the task that decides how a
hand-filed field defect gets a finding id** — it names three candidate schemes and rules one out. Minting
an id for these two now would settle that question by accident, in the one place where doing so cannot be
reviewed. They reach [[fix-next]]'s pool through this epic's `kind: review-intake` stamp instead, which is
the other arm of the same rule and needs no new vocabulary.

**The irony is worth recording rather than smoothing over:** TASK-131 reports that a hand-filed defect
cannot enter the drain pool, and it sat in `tasks/_loose/` — outside the drain pool — for exactly that
reason, until this epic was created to hold it.

## Success criteria

- Both tasks reach `done` with the prose and the tooling agreeing afterwards — a documented rule the tool
  cannot execute is the shape of both defects, so leaving one behind fails the epic.
- Each ships a regression check, per the field-feedback rule: *"a fix for shipped behavior isn't `done`
  until it carries a regression test."*
- **This epic does not become the permanent home for anything a review could have caught.** A finding from
  a close gate belongs in EPIC-002; the divide is the source, not the subject.

## State as of 2026-09-16 — read before picking new work

Created today, holding two tasks re-homed from `tasks/_loose/`. Neither has been started. **TASK-130 is
P1 and is the larger of the two** — it carries an unresolved design decision (roll-up versus
centralisation) that its own acceptance criterion 1 requires be written down *with the counter-argument*,
so it is not an unattended pick: [[fix-next]] excludes tasks whose acceptance is *"decide X"*.

TASK-131 is P2 and is the more self-contained. Its criterion 3 is the sharp one — *the opt-in is exercised
by a test*, because asserting the sentence exists is not asserting the door opens.
