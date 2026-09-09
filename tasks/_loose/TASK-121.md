---
id: TASK-121
parent: null
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-09
depends-on: [TASK-120]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` should offer to run the task in a subagent, and say when that is the wrong choice

## Context

**Requested by the user, 2026-09-09:** *"when i use task pick can it offer to run it in subagent — if i am
correct it would have clean context that way."*

The premise is right, and the distinction is one this repo learned the hard way in TASK-106: **an agent
with no prior conversation is not an agent with no context.** A subagent starts with a fresh window but
still loads the project guide and the installed skills. For a cold drill that is contamination; for
running a task it is exactly what you want — clean of session drift, still holding the rulebook.

### The preconditions already exist, deliberately

| Built for this | Where it says so |
|---|---|
| task files are self-contained | [[tasks]] SKILL.md — *"so a human or AI agent can pick it without re-discovery"* |
| progress survives a lost session | `## Progress log` — *"an interrupted run resumes from disk rather than from conversation memory"* |
| detached execution already works | [[fix-next]] runs unattended and drives `close` itself |

`pick` step 9 already spawns — but **only** when `assignee:` names a specific agent. The generic case
says *"this conversation can begin work directly"* and never offers the choice.

### The design question, which is the real work

**Detached is wrong for some tasks, and the offer must say which.** The measured counter-example is this
repo's own TASK-106: it needed five user decisions during its plan grill and two more at close. A
subagent would have stalled or guessed. So the offer needs a stated test — not taste — for when a task
can be run detached.

### The rule that governs the answer

`close --unattended` is the precedent and the trap. AGENTS.md: **"a flag that declares an absent
capability must define behaviour at every point that needs it"** — and `close`'s own contract table
exists because `--unattended` shipped covering one step while three others still asked. A subagent run
is an unattended run, so **`pick`'s own asks must each get a row**: the plan offer, the `spawn` offers
when scope surfaces mid-work, and the handoff to `close`.

Getting that wrong reproduces the exact defect TASK-050 fixed, one verb over.

## Acceptance criteria

- [ ] `pick` offers a detached run for the generic assignee case, as an offer with a default, not a
      silent change of behaviour
- [ ] A **stated test** decides when detached is appropriate — mechanical acceptance criteria versus ones
      needing judgement — written so two readers reach the same answer on the same task
- [ ] Every point in a detached `pick` that would otherwise ask the user has defined behaviour, in one
      table, the way `close --unattended` does: the plan offer, mid-work `spawn`, and the close handoff
- [ ] What the subagent is handed is specified — the task body is the brief, and what else (the rulebook
      is loaded for it; the conversation is not)
- [ ] How its result returns is defined: what the parent session sees, and where the progress log is
      written so an abandoned run is resumable
- [ ] A detached run that hits a decision it cannot take **stops and reports**, rather than guessing —
      and the task file records where it stopped
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Fixing the dispatch it hangs off** — TASK-120, named in `depends-on`. Adding a branch to a table
  whose branches match nothing would bury this behind that bug.
- Changing `fix-next`, which already runs detached and has its own contract.
- Running a *whole story* detached. One task at a time is the unit `close` gates; a batch is a different
  design and its own task if wanted.

## Human test plan

- [ ] Pick a genuinely mechanical task detached and a judgement-shaped one detached. Expected: the first
      completes and returns something the parent can close; the second stops at its first real decision
      and says so, with the stopping point recorded on the task. Withhold both expectations from the
      runner's brief.

## Notes on placement

**Deliberately loose.** [[tasks]] § *A task outside a pool* has two arms, and this is the second: it is
not a review finding, so filing it into a `kind: review-intake` epic would make that pool misreport how
much of a review is left. It is also not tree hygiene — it is a real capability — so it is **filed but
unranked**, and `/fix-next` will not see it. That is a known cost, accepted here because the requester
knows it exists. If more user-requested capabilities arrive, they want an epic of their own rather than
accumulating loose, which is the failure TASK-040 measured at 17 tasks.
