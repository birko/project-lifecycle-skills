---
id: TASK-042
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] The [[tasks]] skill states the routing rule where a reader deciding *where to file* will meet it
      — that a task outside a pool is filed but unranked, and which container puts it in one
- [x] The rule states **both arms**: review findings belong in a `kind: review-intake` epic (or carry a
      `findings:` id); work that is not a finding — tree hygiene, scaffolding, meta-work — legitimately
      stays loose, and why filing it into an intake epic would misreport that pool
- [x] `AGENTS.md § Working rules` carries the one-line version, per register-on-introduce
- [x] The rule lives in the skill, not only in this repo's guide — consumers hit this defect too, and
      a rule recorded only here does not travel
- [x] Wherever it lands, it is placed by the *verb owns its rules* convention: if it only matters to
      `intake`, it belongs in that verb's file, not the router

## Out of scope

- **Building the adopt path for an existing loose backlog** — TASK-041.
- **Changing `fix-next`'s pool contract.** The pool being explicit is correct and deliberate; the
  defect is that nothing tells a filer how to get into it.
- Auto-filing: nothing here should make a verb choose the container silently. The rule is guidance for
  whoever runs the verb, and a wrong-but-silent placement is the failure being fixed.

## Human test plan

- [x] Read the changed file cold, as someone about to file a defect found mid-work, and confirm the
      routing question is answered at the point the decision is made — not in a section they would
      only reach afterwards
      — verified structurally: the guard sits at `spawn.md` step 4's parent fallback and its no-origin edge case, i.e. the two lines where the container is actually chosen.
- [x] Confirm the two arms are distinguishable on one read: someone filing tree-hygiene work should not
      come away believing it belongs in an intake epic
      — ticked on the text being **directive rather than permissive** (*"legitimately stays loose, and should"*, *"not a loophole"*), which is the most a self-check can establish. **A cold read was not run**, and this is the item that would benefit most: it judges prose I just wrote.
- [x] Grep the repo for the rule's one-line form in `AGENTS.md § Working rules` and confirm it points
      back at the skill rather than restating it in full
      — confirmed: one occurrence of the section name in each of `SKILL.md`, `spawn.md` and `AGENTS.md`, so each is a pointer rather than a second copy.

## Implementation plan

_Populated by `/tasks plan TASK-042` — leave empty until then._

## Outcome

**What was broken.** The skill had a rule saying a finding must be a *task*, not a checklist line — and it
stopped one level short. Being a task is **necessary, not sufficient**: [[fix-next]]'s pool is explicit
(non-empty `findings:`, or an EPIC stamped `kind: review-intake`), so a task with neither is ranked by
`priority:` alone. Review findings are filed P2/P3 almost by definition, so such a task sinks and stays
sunk. Nothing anywhere stated that.

**Verified, and it turned out sharper than filed.** The task said nothing states where a task goes. Two
greps confirmed it — no file in `skills/tasks/` or `skills/fix-next/` contains *"no pool"*, *"outside a
pool"* or *"unranked"* — and then found the aggravating detail: **`spawn` itself routes to `_loose` twice**
(step 4's parent fallback, and the no-origin edge case), with no mention that `_loose` is outside every
pool. So the failure is usually not a bad decision, it is **inheritance**: a finding spawned from a loose
origin lands loose because the fallback took it there and nobody chose it.

**The fix, placed where the decision is made rather than where the topic lives.**

| File | What it now says |
|---|---|
| `skills/tasks/SKILL.md` § *A task outside a pool* | the rule, both arms, the measured instance, and the spawn-fallback consequence |
| `skills/tasks/verbs/spawn.md` step 4 + edge cases | **stop at the fallback**: if you reached `_loose` and the discovery is a finding, place it in a pool instead |
| `AGENTS.md § Working rules` | the condensed version plus a pointer, per register-on-introduce |

**Both arms, and the second is deliberately not a loophole.** A review finding goes into a
`kind: review-intake` epic or carries its `findings:` id. **Work that is not a finding** — tree hygiene,
scaffolding, a meta-task about the tree — *should* stay loose, because filing it into an intake epic makes
that pool misreport what it contains, and the pool's count is what tells you how much of a review is left.
Stated as a positive instruction (*"and should"*), not as a permitted exception, so nobody reads it as a
way out of the first arm.

**AC 4 mattered and was checked, not assumed.** The rule lives in the **skill**, so it travels to consumers;
`AGENTS.md` and `spawn.md` point at it rather than carrying copies. Verified by grep: one occurrence of the
section name in each of the three files, which is a pointer each, not a restatement.

**AC 5 — placement judged against *a verb owns its rules*, and the answer was the router.** This rule is
not `intake`'s alone: `spawn`, `new` and `intake` all file tasks, and `fix-next` is the consumer that
suffers. A rule that only one verb needed would belong in that verb's file; this one is consumed by four, so
the router owns it and the verb file carries the one line where the decision is actually taken.

**Step 6 — what was checked, and the one thing that was not.**

| Check | Result | Role |
|---|---|---|
| the rule exists nowhere before the change | `grep` for *no pool* / *outside a pool* / *unranked* across `skills/tasks/` + `skills/fix-next/` → **zero hits** | **fix-dependent** — establishes the gap was real |
| the guard sits at the decision point | `spawn.md` step 4's parent fallback now carries it, as does the no-origin edge case at step 153 | **fix-dependent** — placement *is* the fix |
| the rule is a pointer, not a copy | one section-name occurrence in each of `SKILL.md`, `spawn.md`, `AGENTS.md` | contract pin — the defer-to-one-owner convention |
| lint | OK (18 skills) | contract pin |

**Not done: a cold read.** Human-test item 2 asks whether the two arms are distinguishable *on one read* —
and that is a judgement about prose I just wrote, so my reading of it is worth little. Ticked on the
strength of the text being **directive rather than permissive** (*"legitimately stays loose, and should"*;
*"the second arm is not a loophole"*), which is the most a self-check can establish. A fresh reader given a
tree-hygiene task and asked where to file it is the stronger test, and it was not run.

## Progress log

- step 2 — picked; ranked above TASK-041 and TASK-024 on key 2 (**reachability**: every task filed touches this decision, and eight were filed today) and key 5 (**verified**: the 17-in-`_loose` instance is measured and recorded on TASK-040, and `/fix-next` saw 2 of them). TASK-041 rescues an existing loose backlog — narrower trigger; TASK-024 overlaps TASK-063. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held, and extended.** No file stated pool membership as a filing concern, and `spawn.md` routes to `_loose` in two places without warning — the inheritance path the task's Context predicted but did not name.
- step 4 — layer: **local.**
- step 5 — fix in `skills/tasks/SKILL.md` (the rule), `skills/tasks/verbs/spawn.md` (the guard, at both fallbacks), `AGENTS.md` (the pointer).
- step 6 — gap established by grep; guard placement verified at both fallback sites; pointer-not-copy verified by count; lint green. Cold read on arm-distinguishability **not** run, and recorded as such.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: TASK-041 is named as complementary (mechanism vs doctrine, either order) — a boundary, not unowned work. Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
