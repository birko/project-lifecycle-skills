---
id: FEATURE-003
created: 2026-09-30
owner: František Bereň
# status — one of: idea, review (built, sign-off pending), done, dropped, superseded
status: review
---

# Task states follow common practice — "blocked" becomes a flag

> Stakeholder-readable. A project manager or end user should understand the problem and the proposed shape without reading any code.

## Problem

A task today has six states: to do, in progress, awaiting check, blocked, done, cancelled. Two of them
behave differently from the tools people already know (Jira, Linear, GitHub Projects, Kanban boards):

- **"Blocked" is a state of its own, and it covers two different situations:** "waiting on something
  else" and "the work is finished, but merging it has to wait". Because it replaces the state the task
  was in, unblocking a task that was already being worked on sends it back to "to do", as if nothing had
  been done on it.
- **"Awaiting check" is called `review`.** Everywhere else, "review" means someone reviewing the code.
  Here it means a person still has to try the finished work by hand.

The owner tried both behaviours side by side in the state-model playground. For both cases that differ, they chose the
common-practice version: *"1 určite druhý, stav rozpracovaná; 6 takisto rozpracovaná, keďže niečo na nej
už bolo spravené"* (in both cases the task should stay in progress, because work was already done on it).

## Proposed shape

Five states instead of six: **to do, in progress, awaiting verification, done, cancelled.** "Blocked"
becomes a **flag** with a reason, and a task can carry it in any open state. The state says where the work
is; the flag says it cannot move on right now. Unblocking removes the flag and leaves the task where it
was. "Finished, but the merge has to wait" is an in-progress task with a "merge deferred" flag, so "done"
still means merged. "Awaiting check" is renamed "awaiting verification", in the files as well.

Every project already using these skills has task files written the old way, so a one-time migration
rewrites them. For each blocked task, it works out from the file's history which state the task was in
before it was blocked.

## Open questions distilled from the grill

- How is a blocked task represented, and where can it sit? → D1
- Where does an unblocked task go? → D2
- What is "finished, but the merge must wait" now? → D3
- Rename the stored value `review` too, or only its name in prose? → D4 (owner: rename the value too)
- What happens to existing blocked tasks in consumer repos? → D5 (owner: rewrite them once)
- Does a blocked task still appear in the work that `pick` and `fix-next` offer? → D6 (owner: yes, with a warning)
- Can a blocked task be started or finished? → D7. This conflicts with D6, so choosing a blocked task has to offer to unblock it first
- How does the flag appear on GitHub Issues and Jira, for projects that sync? → D8
- `fix-next` runs with nobody present, so it cannot ask "unblock and start?". What does it do with a blocked task it ranks first? → D9

## Out of scope (initial)

- Simplifying the rest of the lifecycle (idea → prototype → decisions → tasks). The owner confirmed the question was about the task states only.
- Changing the states of stories and epics (planned, in progress, done, cancelled). They have no "blocked" state today.

## Prototype

Built — the state-model playground (TASK-124's test instrument), published at
https://claude.ai/artifact/GHk9TKVgAHws8snCjj2KaY. Version 5 shows today's model and the proposed one
side by side. It answered D1, D2 and D3; delete it once those are stamped.
