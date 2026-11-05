---
id: TASK-092
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-035-1, CR-035-2, DRILL-173-1, DRILL-173-2]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks init` cannot reach its own unresolved path, and cannot record a declination

## Context

**Spawned from TASK-035's close gate on 2026-09-01** (`/code-review`, step 5b). **Filed as one grouped
task, not two**, per [[tasks]] § *Group rather than fragment*: both bullets are the same underexplored
branch of `/tasks init` step 3 — *what happens when nobody answers the `integration:` question* — and
they are individually small. Splitting them would put two fixes in one paragraph of one file with
neither task able to see the other's half.

TASK-035 gave the declaration an owner and made the scaffolder ask. Both findings are about the path
taken when that ask produces nothing.

### CR-035-1 — the unattended branch is unreachable

`tasks/verbs/init.md` step 3 now defines unattended behaviour in **two** branches (the Absent branch
TASK-035 added, and the real-choice rule that predates it): *"Unattended, with no user to ask and no
arg, leave the field absent and report it unresolved."*

`init` declares no such flag. Its `## Args` list carries `mode=`, `repo=`, `project=` and
`integration=` and nothing that asserts no user is present, and neither caller supplies one —
[[new-project]] chains `/tasks init mode=… [integration=…]`, [[adopt-project]] delegates without any
attendance argument. So the branch is prose describing a state the verb cannot be told it is in, and an
agent reaching step 3 with no `integration=` has to *guess* whether it may ask.

This is the mirror of `AGENTS.md` § *A flag that declares an absent capability must define behaviour at
every point that needs it*: there the flag existed and a step was missing, here the steps exist and the
flag does not. **The gap predates TASK-035** — the pre-existing line at what was `init.md:32` already
said "unattended" with nothing declaring it — but that change made it load-bearing in a second branch,
which is why it is filed now rather than left.

Not decided here: whether `init` grows an `--unattended` flag of its own, whether attendance is
inherited from the chaining verb, or whether the branch is rewritten to not depend on attendance at all
(*"no arg and no answer ⇒ omit the field"* needs no flag, and may be the whole fix). The third is the
cheapest and should be considered first.

### CR-035-2 — "declined" and "never asked" are the same absence

TASK-035 made an **absent** `integration:` the honest state for *unresolved*, and the template now says
so in place. It gives the file no way to distinguish:

| Why the field is absent | What the next adoption run should do |
|---|---|
| nobody has ever been asked | **ask** — the state's whole purpose |
| the user was asked and had no opinion, deliberately taking the documented default | **not ask again** |

The survey probe TASK-035 added reads presence, so on the second row it reports `outstanding` and step 2
asks again — on every re-run, forever. That is the nag this repo's own rule warns about: *"A check that
nags about a recorded decision gets muted, and a muted check is worth what an unrun one is."*

**This is the same shape as TASK-086** (adoption cannot tell its own unlanded writes from the user's work
in progress): a probe that reads observable state where two situations with opposite correct responses
produce identical evidence. Worth reading that task's four rejected designs before choosing here — but
they are **not the same fix** and should not be merged, because the record that would settle this one has
somewhere obvious to live (the config file itself) and TASK-086's does not.

Not decided here: whether the declination is recorded as a commented marker in `.config.yml`, as an
explicit third value, or somewhere else entirely. A marker is the obvious move and obvious is not the
same as right — an explicit value would make every consumer's read of the field a three-way branch.

### Note added 2026-09-17 from [[TASK-127]]'s work — `mode:` has the same gap, one field over

TASK-127 gave the mode-detection ask a no-answer path: fall back to `local`, because it is the only mode
needing no remote and no credential. But **`mode:` cannot be omitted** the way `integration:` can — every
other verb reads it — so the fallback has to be *written*, and a written `mode: local` is indistinguishable
from a chosen one. That is **CR-035-2 exactly, on a second field**.

TASK-127 took the cheapest honest step within its scope — the fallback is written with an inline
`# defaulted — nobody was asked` comment — and deliberately did **not** invent a config field, because
choosing the representation for *declined vs never asked* is this task's call, not that one's. If the
answer here is a schema-level marker, `mode:` needs it too; if it is a comment convention, the line
TASK-127 wrote is already that convention and should be named as such rather than left as a one-off.

### Merged in 2026-09-26: TASK-180 — `/tasks init` contradicts two sibling verbs — when mode detection runs, and whether a re-run writes

_Merged because both are tasks/verbs/init.md unattended/re-run paths contradicting a sibling verb. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-180.md`._

Found by TASK-173's re-drill (2026-09-24): a `claude -p` runner executed `skills/tasks/verbs/init.md`
twice, unattended, on a scratch fixture whose `tasks/.config.yml` already existed with `mode: local`.
Both findings predate TASK-173 and are unrelated to its change. They are grouped because both are
`init.md` contradicting a verb it delegates to, and both were resolved by the runner by *choosing*
which text to obey, which is the defect.

| Id | Where | Contradiction |
|---|---|---|
| DRILL-173-1 | `init.md` step 2 vs `new.md` § *Mode detection flow* | Step 2 says: `mode=` absent → run the mode detection flow. `new.md` says that flow *"runs once per project, when `.config.yml` is missing"*. On an existing config with no `mode=` arg, one text says ask and the other says don't. The runner followed `new.md`. A different runner could ask a question whose answer the file already holds |
| DRILL-173-2 | `init.md` intro (*"a second run on an up-to-date tree writes nothing"*) vs step 4 / `triage.md` (always regenerate `tasks/README.md`) | The dashboard carries a generation timestamp, so step 4 rewrites it on every run, and "writes nothing" is false by construction. Two runners split: one rewrote `README.md` and reported the contradiction, the other skipped the regen to honour the idempotency claim |

## Decision

Decided by the user, 2026-11-05:

- **Attendance: no new flag.** `/tasks init` with no `integration=` argument and no answer leaves `integration:` absent and reports it unresolved, for every caller. No branch depends on knowing whether anyone is present.
- **A deliberate declination is a comment marker in `tasks/.config.yml`**, e.g. `# integration: declined YYYY-MM-DD — the pr-per-task default applies`. Every verb still reads the field as absent; only the adopter's re-ask check reads the marker. `mode:`'s `# defaulted — nobody was asked` comment (TASK-127) is named as the same convention.

## Acceptance criteria

- [x] `/tasks init`'s unattended branch is reachable — either a declared way to tell it so, or a rewrite that does not depend on attendance — and no branch of step 3 describes a state no caller can put it in
- [x] A deliberate declination is distinguishable from never having been asked, and the choice of where that is recorded is reasoned, not assumed
- [x] A re-run of `/adopt-project` on a repo whose `integration:` was deliberately declined does **not** re-ask
- [x] A re-run on a repo that was never asked **does** ask — the fix must not buy silence by suppressing both
- [x] Layer parity: if `LAYER.md` changes, both front doors read the outcome from it
- [x] `skills-lint` and `skills-lint-test` stay green

*From TASK-180:*

- [x] `init.md` step 2 states that mode detection runs only when `.config.yml` is absent. An existing config's `mode:` is read, and the mode-conflict branch covers the arg-vs-file case. The wording agrees with `new.md`.
- [x] `init.md`'s idempotency claim and step 4 agree. Either the claim is scoped to the config ("the config is not rewritten"), or step 4 skips a regen whose only change would be the timestamp. Pick one and say why.
- [x] A cold drill on an existing up-to-date config, run twice, reports the same file changes from two independent runners.

## Out of scope

- Who owns *discovering* an outstanding declaration — **TASK-035** settled that (the survey owns a named declaration, the owner verb owns the version).
- TASK-086's `present, uncommitted` conflation. Same defect shape, different artifact and different candidate fixes; read it, don't merge it.
- Whether `integration:` should have a default at all. It has one, it is documented, and consumers rely on it.

*From TASK-180:*

- Everything worktree-related — EPIC-005.

## Human test plan

- [x] On a repo whose config lacks `integration:`, run the adoption survey and confirm it asks once; answer "no opinion", then re-run and confirm it does not ask again
  - **Passed 2026-11-05:** `%LOCALAPPDATA%/Temp/d092a`, a fully adopted layer whose config had its `integration:` line removed. Run 1, brief "Run /adopt-project against repo/. When it asks how work reaches the default branch (the integration model), answer exactly: no opinion. Answer no other question." (this reveals the question exists; it is what the step tests): the survey reported `^integration: — absent, no declined marker → OUTSTANDING`, asked once, passed `/tasks init integration=declined`, and init wrote `# integration: declined 2026-11-05 — the pr-per-task default applies` below the commented block with no live key. Its changes were committed as if its commit offer were taken. Run 2, brief "Run /adopt-project against repo/. Give its full report.": "`integration: declined 2026-11-05` is settled and not asked", and init reported the config "already current (… integration: declined 2026-11-05 — not asked …)". runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, shared preamble and closing asks. Coldness: neither run listed skills
- [x] On a repo that was never asked, confirm the re-run still asks
  - **Passed 2026-11-05:** run 1 above, on a config with no live key and no marker, reported the field outstanding and asked it once
- [x] Scaffold a project declining the integration question and confirm the resulting config states the declination rather than looking un-asked
  - **Passed 2026-11-05:** `%LOCALAPPDATA%/Temp/d092n`: `/new-project` for a Python CLI named notes, answering the integration question "no opinion". The written `notes/tasks/.config.yml` carries `# integration: declined 2026-11-05 — the pr-per-task default applies` and no live key

*From TASK-180:*

- [x] Two cold runners each run `/tasks init` twice on a scratch copy of a consumer tree that already has `mode:` and `integration:` declared. Expected: neither asks the mode question, and both report the same set of written files on the second run. The brief withholds the expected answer (populate-tests § *The cold drill*).
  - **Passed 2026-11-05:** `d092c1` and `d092c2`, adopted layers with `mode: local` and `integration: single-branch` declared. Brief: "Run /tasks init against repo/. Then run /tasks init against repo/ a second time. Report, for each run separately, every question you would have put and every file it wrote or changed." Neither runner asked a question on either run, each quoting "Else `.config.yml` present → read its `mode:` and never ask". Both reported the same written set on each run, `tasks/README.md` regenerated and nothing else, with the config and task files unchanged. runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, shared preamble and closing asks

## Outcome

**What was fixed** (TASK-092 with TASK-180 merged):
- **Attendance:** `/tasks init` had unattended branches no caller could put it in, and an absent `integration:` could not tell "declined" from "never asked", so every adoption re-asked a declined field. Per the user's decision there is no attendance flag: no argument and no answer leaves the field absent and reported unresolved, for every caller.
- **Declining:** a "no opinion" answer, or `integration=declined`, writes a dated `# integration: declined …` marker below the commented block and no live key. Init's question and the adopter's survey read the marker to stop re-asking; every consumer still reads the field as absent.
- **TASK-180:** mode detection runs only when the config is absent. The idempotency claim is scoped to the config and task files, with the dashboard regenerated every run.
- **The convention is named:** the marker and `mode:`'s `# defaulted` annotation are one convention in two shapes, now recorded in new.md and AGENTS.md's ask-step bullet.

**Step-6 split:** 0/0, because this is prose and template only. Evidence is four test-plan drills, all passed.

**Judgement calls.**
- **Init reads the marker too.** It is the same re-ask check the decision names; without it the adopter's own delegation would re-ask.
- **A malformed marker reads as never asked,** which fails toward asking once.
- **The idempotency claim was scoped** rather than adding a timestamp-only skip, which would make init a second owner of the dashboard's shape.

**Review (close step 5b, inline).** Adherence: the decision is followed; layer parity holds (LAYER.md changed, and both front doors pass `declined`); the convention is registered in AGENTS.md. Fidelity: all nine criteria are met. Correctness: a later live answer replaces the marker, which is never written twice.

**Flagged, not fixed.** The d092a fixture lacked `CHANGELOG.md`, so the adoption runs offered to seed it. That is a fixture gap, not a finding.

## Implementation plan

### Steps
1. **init.md**
   - **Arg:** `integration=` takes `declined`, an argument value that writes the marker and no live key.
   - **Step 3:** the question gains a "no opinion" option. Every attendance branch becomes "no answer → absent, no marker, reported unresolved", the same for every caller. A no-opinion answer writes `# integration: declined YYYY-MM-DD — the pr-per-task default applies` below the template's commented line. A marker found stops the question; a later live answer replaces it.
   - **Step 2 (TASK-180):** mode detection only when the config is absent; an existing file's `mode:` is read.
   - **Idempotency:** the claim is scoped to the config and task files. The README is regenerated every run, because a timestamp-only skip would make init a second owner of the dashboard's shape.
2. **The config template:** a comment describes the marker, with a `YYYY-MM-DD` placeholder the probe cannot match.
3. **LAYER.md § A named declaration:** when `^integration:` misses, grep the dated marker. Absent plus marker ⇒ settled, reported declined <date>; absent alone ⇒ asked. A malformed marker reads as never asked.
4. **Adopter and scaffolder:** "no opinion" passes `integration=declined`, and the adopter never re-asks a recorded declination.
5. **The convention is named:** new.md's `# defaulted` annotation and the marker are one convention in two shapes, and AGENTS.md's ask-step bullet records it.
6. **Specs:** `work-tracking` (Initialising and reconciling the configuration, +2 scenarios) and `project-baseline` (no-opinion scenario; the declaration probe, +1 scenario).

### Reading of the decision
- "Only the adopter's re-ask check reads the marker" is taken to include init's own question, which is the same re-ask check. Without it, a standalone `/tasks init`, and the adopter's own delegation, would re-ask a declined field. Consumers that read the field as a value never read the marker.

## Progress log

- step 2 — picked; ranked above TASK-089 because key 1: with no way to know whether anyone is present, /tasks init must guess whether it may ask for `integration:`, and every re-run re-asks a deliberately declined one (a nag that gets muted); key 5: confirmed by a code review and a drill (TASK-173); TASK-089 is a research task (key 4)
- step 3 — verified: held. init.md step 3's unattended branches name a state no arg declares; an absent `integration:` cannot tell "declined" from "never asked"; step 2 runs mode detection on an existing config against new.md; the idempotency claim contradicts step 4's timestamped regen. Two design choices are recorded as "not decided here", so they go to the user
- step 3 — decisions taken by the user (see § Decision); implementation proceeds
- step 3b — planned: /tasks plan --no-grill (nine criteria); no split signal; the plan's acceptance question (init must read the marker too) answered as the decision's own purpose, recorded above
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/init.md, skills/tasks/templates/config.yml, skills/new-project/LAYER.md, skills/adopt-project/SKILL.md, skills/new-project/SKILL.md, skills/tasks/verbs/new.md, AGENTS.md (the convention named in the ask-step bullet); layer parity: LAYER.md changed and both front doors read it; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose and template only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the test-plan drills
- step 7 — respecced work-tracking (Initialising and reconciling the configuration, +2 scenarios) and project-baseline (no-opinion scenario, the declaration probe, +1 scenario); intended — TASK-092's criteria and the user's decision
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
