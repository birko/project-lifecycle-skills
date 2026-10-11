---
id: TASK-133
parent: STORY-017
feature: null
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-131]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-131-1, DRILL-131-1, DRILL-131-2]
pr: null
github-issue: null
jira-key: null
---

# `spawn`'s pool rescue fires only for a review finding, so a field-shaped discovery still lands loose

## Context

Spawned by the `/code-review` pass at [[TASK-131]]'s close gate, 2026-09-17. `CR-131-1`.

`skills/tasks/verbs/spawn.md` step 4 tells the caller, when the parent fallback bottoms out at `_loose`:

> **If you reach `_loose` and the discovery is a review finding, stop and place it in a pool instead** —
> `_loose` with no `findings:` id and no `kind: review-intake` ancestor is outside [[fix-next]]'s pool
> entirely, so the task is filed and unranked.

That rescue is **conditioned on the discovery being a review finding**, and when it was written that
condition was doing no harm: a discovery with no pass behind it had no id it could have been given, so
naming it would have pointed at nothing. TASK-131 removed that constraint — `/tasks new task --from-field`
now mints a `FIELD-NNN` for exactly the pass-less case — and the condition became a live gap instead of a
tautology.

### The mechanism

A `/fix-next` run is the common origin. Its step 5 discovers something adjacent that is a genuine defect
but was **not** raised by any review pass — nobody code-reviewed it, it came out of doing the work. Spawn
parents it to the origin's STORY, else EPIC, else `_loose`. If the origin is itself loose, the discovery
lands loose, the rescue does not fire because the discovery is not a *review* finding, and the task is
filed with `findings: []` under no `review-intake` ancestor — outside the pool, ranked by `priority:`
alone. This is the identical end state TASK-131 fixed at the front door, reached through a side one.

**Why it is small but not nil:** the rescue's own precondition (a loose origin) is uncommon, and this
repo's `_loose/` holds one task. But the rule exists precisely for the case nobody chooses — the
SKILL.md text says so: *"a finding spawned from a task that is itself loose lands loose by inheritance,
with nobody choosing that."*

### Merged in 2026-09-26: TASK-137 — The `--from-field` door opens, but two of its edges are undefined — a cold runner reached both by inference

_Merged because both are --from-field follow-ups from TASK-131. The original file stays, cancelled, at `tasks/EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-137.md`._

**From TASK-131's cold drill, 2026-09-17** — the drill that confirmed the door itself works. The runner
**passed every arm of the pass/fail bar**, so neither of these is a failure of that task; they are the two
places it had to reason past the text to get there, and it logged both as inferences rather than reads.
That is the shape this repo treats as a defect: *"a rule three readers must each reconstruct is a rule
that is not written down."*

#### DRILL-131-1 — the mint rule has no empty case

`new.md`'s `--from-field` step says to grep every `findings:` list tree-wide for the current max
`FIELD-NNN`, increment, and zero-pad. **It never says what the first one is.** The runner's own words:

> *"The mint rule says 'take the max, increment' and never states the empty case. I took it from new.md
> step 6's parallel rule for task ids (`First of a type: EPIC-001 / STORY-001 / TASK-001`) plus the
> zero-pad-to-three instruction."*

It landed on `FIELD-001`, which is right. The defect is that it is right **by analogy to a different
rule about a different counter**, so a second runner is free to land on `FIELD-000`, `FIELD-1`, or to
stall. Every field report is a first one until it isn't.

#### DRILL-131-2 — "joins the same way" names a route, not a scope

`fix-next` § Step 1: *"An already-filed task joins the same way — mint the id by that route and write it
in."* `new.md`'s `--from-field` block is written as steps inside a **create** flow, and its later steps
have no meaning for a task that already exists — step 11 regenerates the dashboard, step 12 auto-runs
`plan`. The runner:

> *"'The same way' names the route, not how much of it applies. I ran the mint and the write, and stopped."*

Stopping was the sensible reading, and nothing says it is the right one. A runner that instead ran step 11
would regenerate a dashboard; one that ran step 12 would draft an implementation plan onto someone else's
filed task. Three defensible readings, no rule.

## Acceptance criteria

- [x] 1. `spawn.md`'s `_loose` rescue covers a discovery with **no pass behind it**, not only a review
      finding, and names `--from-field` as the route that gives it an id.
- [x] 2. The rescue does **not** widen into "anything spawned into `_loose` joins the pool". Tree hygiene
      and meta-work about the tree legitimately stay loose and unranked — [[tasks]] SKILL.md § *A task
      outside a pool* calls that arm explicitly not a loophole, and this must not quietly overturn it.
      Whatever wording lands has to keep the two distinguishable.
- [x] 3. Whatever `spawn.md` ends up asserting about `--from-field` is pinned by `skills-lint.sh`
      check 4 — i.e. if it names the flag in an invocation, the receiving verb must still declare it.

*From TASK-137:*

- [x] `new.md`'s `--from-field` mint states the first-id case explicitly, rather than leaving it to
      analogy with the task-id counter
- [x] The already-filed path states **which** of `new`'s steps apply to it and which do not — by naming
      them, not by a general sentence a reader must scope themselves
- [x] Both are stated where the runner actually reads them; a rule added only to `fix-next` does not
      reach someone who entered through `/tasks new`
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `--from-field` mechanism itself — built and closed under [[TASK-131]]; this task only routes to it.
- [[TASK-130]] — cross-repo collection, a separate mechanism, and still undecided.

*From TASK-137:*

- The `--from-field` door itself, and the `FIELD-*` prefix — both work, [[TASK-131]] drilled them.
- The field-report `## Context` standard (*"repo, version or invocation"*) for an **already-filed**
  task. The runner raised it as a third undecided point and it is a weaker claim: the requirement is
  written for a task being created, and whether a pre-existing one must be backfilled to it is a
  question about filing standards, not about this door. Settled by the fix: `new.md`'s already-filed path
  does not redraft an existing task's Context (see Outcome).

## Human test plan

N/A — fully covered by the lint. AC1 and AC2 are prose judgements a reader checks at review, and AC3 is
`skills-lint.sh` check 4, which already fails on an undeclared flag (proven by TASK-131 step 6). A cold
drill would add nothing here: this task changes the *condition* on a rescue whose behaviour TASK-131's
own drill already exercises, so a second runner would be re-reading the same paragraph.

*From TASK-137:*

- [x] Re-run TASK-131's drill recipe on a tree with **no** `FIELD-*` id anywhere and a hand-filed defect
      task, with a cold runner, and confirm the report cites a rule for the first id rather than deriving
      one. Then re-run it on a tree that already has `FIELD-001` and confirm the increment still holds.
  - **Passed 2026-10-11:** cold `claude -p` runs on `%TEMP%\d133` (a loose hand-filed crash report, `findings: []`). With
    no `FIELD-*` anywhere, the runner wrote `[FIELD-001]` quoting "When no copy holds any `FIELD-NNN`, the first is
    `FIELD-001`". With `FIELD-001` on another task, it wrote `[FIELD-002]`. Each made one edit and quoted the
    already-filed path for every step it skipped. Brief: "get TASK-002 into /fix-next's pool, do what the skills
    say and nothing more, quote the rule for each change", with no expected id. Runner: `claude -p
    --permission-mode acceptEdits --allowedTools "Bash(git:*)" Read Grep Glob Edit Write --add-dir
    C:/Users/FinStat/.claude/skills C:/Source/project-lifecycle-skills`, run from the fixture. Coldness: the
    brief withheld the answer. The runner holds the installed skills, which a behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-133` — leave empty until then._

## Outcome

**The fix.** A defect discovered while doing other work, with no review pass behind it, used to be filed
outside `/fix-next`'s pool whenever its origin task was loose, because `spawn`'s rescue only fired for a
*review* finding. The rescue now covers any defect and sends a pass-less one through
`/tasks new task --from-field`, which mints the id that puts it in the pool. Work that is not a defect stays
loose, as SKILL.md § *A task outside a pool* intends. `new.md` now states that the first field id is
`FIELD-001`, and gives an already-filed defect a named path: the mint, the write into its `findings:`, and
the report run; creating, redrafting, the dashboard and the plan do not. `fix-next` step 1 points there.

**Step 6 split.** The drill (`%TEMP%\d133`, a hand-filed loose defect) reached the same end state with and
without the fix: one edit, `findings: [FIELD-001]`. **That end state is a contract pin, not evidence.** What
the fix changed is the grounding. The reverted runner derived the first id and scoped the path by itself
("I wasn't creating a task"). Both fixed runners quoted the new rules, and the second one minted `FIELD-002`
over an existing `FIELD-001`. **AC3 is fix-dependent:** with `--from-field` renamed in `new.md`, lint check 4
failed on both invocations, including `spawn.md`'s new one, and it passes with the declaration restored.

**Judgement calls.**
- *"Carry an id" rather than "move it into an epic".* An id in `findings:` puts a task in the pool wherever
  it sits, so the rescue does not force a move. Moving every loose defect was the stricter option, rejected
  because it would refile tasks for no ranking gain.
- *The test is "something broken", not importance.* AC2 needs the two arms kept apart. A rule about how
  much something matters would let any important cleanup into the pool and make the pool misreport its
  size.
- *The already-filed path does not redraft Context.* A runner could backfill the field-evidence standard on
  an existing task. The path rules that out, because the task is someone else's. This settles the third
  point TASK-137's runner raised. It was in Out of scope as "file separately if it recurs".

**Flagged, not fixed.** Two of the three drill runners pointed out that the already-filed path leaves its one
edit uncommitted, and neither skill says who commits it. This is the authoring-verb norm (`pick`, `cancel`
and `block` do not commit either; TASK-294's Outcome records why), so nothing was filed.

## Progress log

- step 2 — picked; ranked above TASK-295 because both give a silent wrong result behind an uncommon precondition (keys 1–3 tie), and TASK-133 is a scoped prose change while TASK-295 carries an open design question, which of two readings is right (key 4). Key 6 inert: separated on keys 1–5
- step 3 — verified: all three held as written — `spawn.md` step 4 conditions the `_loose` rescue on "a review finding" (its edge case says "a finding", unqualified); `new.md`'s `--from-field` mint never states the first id; `fix-next` step 1's "joins the same way" points at steps written only inside a create flow. A `findings:` id alone puts a task in the pool wherever it sits, so the rescue can be "carry an id", not "move it"
- step 4 — layer: local (`skills/tasks/verbs/spawn.md`, `skills/tasks/verbs/new.md`, `skills/fix-next/SKILL.md`)
- step 5 — fix in `skills/tasks/verbs/spawn.md` (step 4's `_loose` rescue covers any defect, review-raised or not, routes a pass-less one through `/tasks new task --from-field`, and keeps non-defect work loose; edge case aligned), `skills/tasks/verbs/new.md` (`FIELD-001` as the first id; an already-filed path naming what runs and what does not), `skills/fix-next/SKILL.md` (step 1 points at that path); tests: lint green, check 4 now reads `spawn.md`'s invocation; drill on `%TEMP%\d133` (hand-filed loose defect) — no ids → `FIELD-001`, `FIELD-001` present → `FIELD-002`, one edit each, every skipped step named and quoted
- step 6 — reverted (pre-fix `new.md`, `spawn.md`, `fix-next` for one run, then restored): the reverted runner reached the same single edit and `FIELD-001`, so the end state is a contract pin, not evidence; fix-dependent = the grounding, the reverted report derives the first id ("none contains a FIELD id, so the next is FIELD-001") and scopes the path by itself ("I wasn't creating a task"), where both fixed runs quote the new rules. AC3: with `--from-field` renamed in `new.md`, check 4 failed 2/2 invocations including `spawn.md`'s new one (exit 1); restored, it passes — fix-dependent
- step 7 — respecced work-tracking ("Tasks born from findings": first id and the already-filed path, plus a scenario; "Spawning discovered work": the rescue covers any defect, plus a scenario) and defect-draining ("The pool is explicit, never inferred": the already-filed route); `generated-at` restamped on both
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
