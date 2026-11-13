---
id: TASK-139
parent: STORY-017
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: agent
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-130]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-130-5]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `nextUpTasks[]` sorts on two keys that routinely tie, and says nothing about the third

## Context

**From TASK-130's cold drill, 2026-09-17** — found while drilling something else, and **pre-existing**:
it is a defect in the Collection pass's long-standing sort, not in the `--across` change that exposed it.
Spawned rather than folded in for exactly that reason.

§ *Collection pass* step 5:

> `nextUpTasks[]` — TASKs with `status: todo` (NOT blocked), sorted P0→P1→P2 then created asc

The runner hit a four-task fixture where **every task was `P2` and every `created` was the same date**,
and had to invent an order for the "Next up (top 3)" list — which then decides which task a human is shown
and which is cut. Its own words: the tie-break *"is undecided, and the top-3 cut makes it visible."*

**This is the same defect [[fix-next]] § Step 2 already names for its own ladder** — *"`created` is a date
with no time, and `/tasks intake` files an entire pass in one of them, so it ties routinely: twelve tasks
in this repo share `2026-08-20`."* That skill responded by declaring key 8 the last resort **and requiring
a run to say when the keys were exhausted**. The Collection pass's sort never got the same treatment, so
where `fix-next` announces a degenerate ranking, the snapshot silently picks three.

**Why it matters more with `--across` than without**, though it is not caused by it: merging several
projects multiplies ties, because two projects that each filed a batch on one day now interleave with no
key that can separate them. The drill's fixture was 4 tasks and already fully degenerate.

### Rescoped 2026-11-13 by `/fix-next` step 3 — the same sort is written in three places

Re-verification found the defect as described, in three places with one root cause:

- `skills/tasks/SKILL.md` § *Collection pass* step 5, `nextUpTasks[]`: "sorted P0→P1→P2 then created asc". This
  names three priorities while the same pass's step 4 says a fixed `{P0, P1, P2}` set "silently drops any other
  value in use". So a `P3` task has no stated place in the order either.
- The same step's `inProgressTasks[]`: "sorted by priority then created". This sort ties the same way.
- `skills/tasks/verbs/pick.md` step 4: "ordered by priority (P0 first), then created date". This is a restated copy
  of the sort. It numbers the list a person picks from, so a tie renumbers it between runs.

The fix is one order, stated once in § *Collection pass*, which the other lists point at. The criteria below are
widened to cover the other two places. None of the declared keys changes.

## Acceptance criteria

- [x] The sort states a **total order** — a final tie-break that cannot itself tie (id, or repo-qualified
      id in across-mode), so two runs over one tree produce the same three
- [x] A degenerate ranking is **announced**, not silent, matching the rule [[fix-next]] § Step 2 already
      applies to its own ladder — *"a ranking key that cannot discriminate must say so, not pass quietly"*
      (`AGENTS.md` § Conventions)
- [x] The rule lives in § *Collection pass*, so `triage`, `audit`, the snapshot and [[roadmap]] all
      inherit it rather than each re-deciding
- [x] The priority key covers every priority value present, not a fixed `P0→P1→P2`
- [x] `inProgressTasks[]` and `pick`'s numbered list use the same order by pointing at it, never a restated copy
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- [[fix-next]]'s own eight-key ladder — already correct, and the model this should follow.
- Changing *which* keys sort the list. This is about what happens when the declared keys run out.

## Human test plan

- [x] Cold-drill the snapshot against a fixture where every todo task shares one priority and one
      `created` date, and more tasks exist than the top-3 cut shows. **Pass** = the run produces a stable
      order and says the keys were exhausted. The brief must not mention ties or ordering.
  - **Passed 2026-11-13.** The fixture is `%LOCALAPPDATA%/Temp/d139/{fix,old}/repo`, a git repo with one epic and one
    story. It has five `todo` tasks, all `P2` and all `created: 2026-11-01`. They were written in the order
    `TASK-010, 002, 011, 009, 004` and given titles whose alphabetical order is not their id order.
    - `fix/skill` is `skills/` with this fix. `old/skill` is the same with `HEAD`'s `tasks/SKILL.md` and `pick.md`.
    - The brief asked for "/tasks" read-only and never mentioned ties or ordering.
    - The runner command was TASK-065's, with cwd at each fixture's root.
    - **Coldness:** both runners listed no skills and had no Skill tool.
    - **Fixed text:** the runner printed `TASK-002, 004, 009`, then `ordered by id where priority and created tie:
      TASK-002, TASK-004, TASK-009 (+2 not shown) — nobody ranked them`. It cited the Task order table and did not
      list the order as undecided.
    - **Old text:** the runner printed the same three with no line. It listed as undecided: "no further tie-breaker is
      given. I sorted by id ascending… TASK-010 and TASK-011 lost only to that unwritten rule."
    - **Fold-in:** the fixed runner also asked whether hidden tasks that tie only with each other count toward
      `(+N not shown)`. This close settled it in § *Collection pass*: count only the hidden tasks that tie with a
      shown one.
    - **Other findings:** three pre-existing readings both runners raised are filed as TASK-355.

## Implementation plan

Drafted 2026-11-13 by `/fix-next`, as `/tasks plan --no-grill` would write it (triggers: two files, six criteria).

1. `skills/tasks/SKILL.md` § *Collection pass* step 5 gains a **Task order** bullet. It gives three keys:
   - priority: every value present, in the natural order, with no priority last;
   - `created`, oldest first;
   - the id's number, lowest first, which cannot tie within one repo. In `--across` mode, the repo name breaks the
     last tie, since ids collide across repos and `<repo>/TASK-NNN` is unique.
   The bullet also gives the rule for announcing: a view that shows a **ranking** prints one line whenever the id
   key decided an order a reader can see. That line names the tied tasks and says nobody ranked them.
2. `nextUpTasks[]` and `inProgressTasks[]` point at that bullet in place of their own sort phrases.
3. The snapshot's render template (`SKILL.md` § status snapshot step 2) shows where the announce line goes, under
   "Next up".
4. `pick.md` step 4 orders its list by the Collection pass's task order, a pointer rather than a copy, and prints the
   same announce line under the list.
5. Respec: the `work-tracking` area, if the map covers `skills/tasks/`.

## Outcome

**The fix.** Every list of tasks (the "Next up" snapshot, the in-progress list, `pick`'s numbered list) now uses one
order. It is stated once, in `skills/tasks/SKILL.md` § *Collection pass* step 5:
- priority, covering every value present, not only P0–P2;
- then `created`;
- then the id's number, which cannot tie. Across sibling repos, the repo name breaks the last tie.

Where priority and date tie and the id decided what a reader sees, a ranked view prints one line saying so. Before
this, the order stopped at the date. Tasks filed on one day came out in whatever order the reader chose, so two runs
could show a different "Next up" top three, with nothing to say why.

**Step-6 split.**
- **Text assertions:** 7 of 7 fail on `HEAD`'s copies and pass on the fix, all fix-dependent: the id key, no fixed
  P0–P2 sort, every priority covered, the across-repo tie-break, the tie line, the in-progress pointer and `pick`'s
  pointer. The script is `task139-check.sh` in the session scratchpad.
- **Behaviour:** two cold drills on one all-tied fixture.
  - On the old text the runner listed the tie-break as undecided and printed no line.
  - On the fixed text it read the order off the rule and printed the tie line.
- **Contract pins, not evidence:**
  - the order itself (`TASK-002, 004, 009`), since the old runner happened to choose id order too;
  - skills-lint, which passes on both.

**Judgement calls.**
- **The id is the last key, not something more meaningful.** Title order, file order or "most recently touched" would
  each smuggle in a judgement nobody made. The id only makes runs agree, and the tie line says so. Rejected: asking
  the reader to rank. This is a status view, and a question there would block every snapshot.
- **The tie line prints only for views read as a ranking** ("Next up", `pick`'s list). The in-progress list, the
  verification list and the dashboard tree use the order silently. A line there would be noise on every run of a
  normal tree, and a check that nags gets muted.
- **Wider than filed:** the same sort was restated in `pick.md` and in `inProgressTasks[]`, and the spelled-out
  `P0→P1→P2` left `P3` with no place. Fixing only `nextUpTasks[]` would have left two copies to drift, so both now
  point at the one rule.
- **Folded in from the drill:** which hidden tied tasks `(+N not shown)` counts. Only those that tie with a shown one.

**Close gate (inline, about 30 lines of prose):**
- **Standards:** one owner and pointers. The `pick.md` parenthetical that restated the three keys was cut to a pointer
  at the gate, and so was a colon that made its example look like a tie-line example.
- **Intent:** all six criteria met.
- **Correctness:** no issue left after the `pick.md` fix.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.** Three pre-existing snapshot-template readings both drill runners raised (singular counts,
"suppress trailing zeros", which template text is output) → TASK-355, P3. `AGENTS.md` § *A ranking key that cannot
discriminate* still names only [[fix-next]] as its instance. This order is a second one, and was not added because
the rule needs no change to cover it.

## Progress log

- step 2 — picked; ranked above TASK-347 because both are correctness-invariants (key 6 inert: same theme), but this one gives a plausible wrong answer (an unreproducible "Next up" top 3) on the most-run path, every `/tasks` snapshot, `triage` and `/roadmap`, with no signal (keys 1–3), and is one rule in one place (key 4), while TASK-347 is ten wording readings across `pick`. Outline was unreachable, so its roadmap page was not consulted
- step 3 — verified: rescoped: held as filed, plus the same sort in `inProgressTasks[]` and `pick.md` step 4, and `P3` absent from the spelled-out order; Context and criteria corrected before any edit
- step 3b — planned: drafted inline as /tasks plan --no-grill (two files, six criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/SKILL.md (§ Collection pass step 5: a Task order bullet with three keys and the tie announce line; both index sorts and the snapshot template point at it) and skills/tasks/verbs/pick.md step 4 (points at it, captures `created`); assertions in scratchpad task139-check.sh; lint green
- step 6 — reverted fix (HEAD copies): 7/7 assertions failed; fix-dependent = A1 id key, A2 no fixed P0-P2 sort, A3 every priority, A4 across repo tie-break, A5 announce line, A6 inProgressTasks pointer, A7 pick pointer; contract pins = skills-lint (passes on both). Behavioural split: cold drills on HEAD vs fixed text running (d139)
- step 7 — respecced work-tracking (surgical); requirements changed: Collection pass (one total order, the tie line, new scenario "Next-up tasks that tie on every declared key"), Status snapshot and help, Picking a task; intended — TASK-139 criteria 1, 2, 4, 5. shaped-by unchanged: TASK-139 is feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
