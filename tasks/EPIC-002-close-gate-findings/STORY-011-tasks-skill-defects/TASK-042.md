---
id: TASK-042
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Nothing says where a new task is filed, so findings land where nothing can rank them

## Context

Filed by `/verify-conventions` at TASK-040's close gate, as a register-on-introduce finding.

The [[tasks]] skill documents two entry points for review output — `spawn` for a single adjacent
finding, `intake` for a whole pass — and `SKILL.md § Findings become tasks, or they evaporate` explains
why a finding must become a task rather than a checklist line. What no file states is **where the task
goes**, and that turns out to be the load-bearing part:

- A task under an epic stamped `kind: review-intake` is in [[fix-next]]'s pool.
- A task carrying a non-empty `findings:` list is in the pool.
- A task in `tasks/_loose/` with neither is in **no** pool. `pick` and the `Next up` snapshot still
  see it, but rank it by `priority:` — and review findings are almost always filed P2/P3, so in
  practice it sinks and stays sunk.

The skill's own rule about checklist lines ("*only `status: todo` tasks are ranked… if it's worth
doing, it's a task*") stops one level too early. Being a task is necessary and not sufficient; being a
task **in a pool** is the actual bar, and nothing says so.

**Measured instance, this repo:** 17 defect tasks accumulated in `_loose/` between 2026-08-18 and
2026-08-20, every one correctly written, none reachable by the verb built to drain them. `/fix-next`
saw 2. TASK-040 re-homed them; this task stops the next batch from landing there.

The counterpart rule is the one that says what may *stay* loose. TASK-040 itself is the example: it is
tree-hygiene meta-work, not a review finding, and filing it into a `review-intake` epic would misreport
what that pool contains. So the routing has two arms, and both need writing down.

**Relationship to TASK-041:** that task gives `intake` a way to *rescue* an existing loose backlog;
this one stops it accumulating. Mechanism and doctrine — neither substitutes for the other, and they
can land in either order.

## Acceptance criteria

- [ ] The [[tasks]] skill states the routing rule where a reader deciding *where to file* will meet it
      — that a task outside a pool is filed but unranked, and which container puts it in one
- [ ] The rule states **both arms**: review findings belong in a `kind: review-intake` epic (or carry a
      `findings:` id); work that is not a finding — tree hygiene, scaffolding, meta-work — legitimately
      stays loose, and why filing it into an intake epic would misreport that pool
- [ ] `AGENTS.md § Working rules` carries the one-line version, per register-on-introduce
- [ ] The rule lives in the skill, not only in this repo's guide — consumers hit this defect too, and
      a rule recorded only here does not travel
- [ ] Wherever it lands, it is placed by the *verb owns its rules* convention: if it only matters to
      `intake`, it belongs in that verb's file, not the router

## Out of scope

- **Building the adopt path for an existing loose backlog** — TASK-041.
- **Changing `fix-next`'s pool contract.** The pool being explicit is correct and deliberate; the
  defect is that nothing tells a filer how to get into it.
- Auto-filing: nothing here should make a verb choose the container silently. The rule is guidance for
  whoever runs the verb, and a wrong-but-silent placement is the failure being fixed.

## Human test plan

- [ ] Read the changed file cold, as someone about to file a defect found mid-work, and confirm the
      routing question is answered at the point the decision is made — not in a section they would
      only reach afterwards
- [ ] Confirm the two arms are distinguishable on one read: someone filing tree-hygiene work should not
      come away believing it belongs in an intake epic
- [ ] Grep the repo for the rule's one-line form in `AGENTS.md § Working rules` and confirm it points
      back at the skill rather than restating it in full

## Implementation plan

_Populated by `/tasks plan TASK-042` — leave empty until then._
