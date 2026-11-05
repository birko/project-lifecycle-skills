---
id: TASK-100
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-086-4]
pr: null
github-issue: null
jira-key: null
---

# Step 3c derives its set from what a run *created*, and landing is the one act that invalidates without creating

## Context

**From the 2026-09-01 cold drill of `adopt-project` on a cloned consumer with constructed git state.**

Step 3c says an adoption that **creates** an input to a generated file owes a re-run of that file's owning
verb, and is explicit that the set is derived from creation rather than from survey rows:

> *"An adoption that creates an input to a generated file owes a re-run of that file's owning verb."*
> *"3c derives its set from what this run **actually created**, not from a list here."*

**Landing an unlanded file creates nothing and invalidates a generated file anyway.** The measured case: an
untracked `tasks/_loose/TASK-022-…md` is offered for landing; `tasks/README.md` was generated before it
existed and does not list it. Take the offer and the dashboard is stale against history the moment the
commit lands — but this run created nothing, so 3c's set is empty by its own derivation rule and the step
never fires. The runner found the hole and declined to act on it:

> *"The step is written around **creation**, and a landing is the one act that changes what a generated
> file should say without creating its input. … hand-shaping a generated file to fix it is forbidden and
> re-running it uninvited is outside 3c's derived set."*

So it correctly did neither, and raised it as a question instead. That is the right behaviour and it should
not require a runner to reason its way there.

### Why the obvious fix is wrong

**Do not widen the trigger to "created or landed".** A landing is not always an invalidation — landing a
`.gitignore` or a `CHANGELOG.md` feeds nothing — and 3c's whole design is that the set is *derived*, never
listed, precisely so it stays correct as the layer grows. A second trigger word invites the same list-drift
the step avoided.

The shape that fits the existing rule: 3c already asks, of each artifact the run touched, *"is anything's
output computed from this?"* The defect is that **"touched" is currently spelled "created"**. Landing is a
touch. So is an owner verb's amendment, which raises the same question one step further out and should be
checked while the fix is open.

**The ordering constraint already in the file must survive.** Step 3's *land before any re-run that would
rewrite the same file* is explicit and load-bearing — landed-then-overwritten is a `git revert` away,
overwritten-then-landed is gone. Any regeneration this task adds happens **after** the landing, never
instead of it.

**And the no-op invariant must survive too.** 3c's own table says a pure no-op *"writes nothing, and says
nothing"*. A landing that turns out not to change a generated file's content must stay silent rather than
announcing a regeneration it did not perform.

## Acceptance criteria

- [x] Landing an unlanded artifact that is an input to a generated file triggers the owning verb's re-run, without widening 3c into a list of trigger verbs
- [x] The derivation stays a derivation — the set is still computed by asking what reads the touched artifact, not enumerated in prose
- [x] An owner verb's **amendment** of an existing artifact is checked against the same question, and either covered or explicitly excluded with a reason
- [x] Step 3's land-before-rewrite ordering is unchanged and still explicit
- [x] A landing whose regeneration is a pure no-op still writes nothing and says nothing
- [x] Layer parity: the rule lands where both front doors read it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Which verb owns which generated file. `LAYER.md`'s Owner column already answers that and 3c already reads it.
- Whether spec bodies are regenerated automatically. They stay an offer — `/specs regen` is real token spend, and 3c says so.
- The `present, uncommitted` offer's shape — **TASK-086** settled that; this is what happens *after* the offer is taken.

## Human test plan

- [x] Cold-drill a repo with an unlanded task file and a dashboard generated before it, expected answers withheld, and confirm the runner reaches the regeneration question from the instructions rather than deriving it
  - **Passed 2026-11-05 (second run):** `d100a` — a fully adopted layer with `tasks/_loose/TASK-005.md` untracked and `tasks/README.md` generated before it. The runner landed TASK-005, regenerated the dashboard through `/tasks triage` in the same adoption commit (`88fbb9c`; the dashboard now lists TASK-005), and its step 3c names the landed task as an input to the dashboard, so it reached the regeneration from the instructions
- [x] Confirm a landing that feeds nothing generated produces no regeneration and no mention of one
  - **Passed 2026-11-05 (second run):** `d100b` — the same layer with `CHANGELOG.md` untracked. The runner landed it alone (`fd57ca0`), regenerated nothing, and its step 3c quotes "`CHANGELOG.md` … feed nothing" and the no-op rule. The only trace is step 4's fixed `regenerated: (none)` bucket, which reports that nothing was regenerated, not a regeneration

## Outcome

**What was fixed.** `adopt-project` step 3c regenerates generated files (today the task dashboard) when the adoption changed one of their inputs. It recognised only *created* inputs, so landing an uncommitted task file, which creates nothing, left `tasks/README.md` stale with no step owning the re-run. The trigger now reads *touched*, defined by one test: did this run change what the repo holds for the artifact, either its content on disk or whether history carries it? Creating, landing and amending all pass that test, and the rule names no list of trigger verbs.

- `skills/adopt-project/SKILL.md` § 3c: the trigger sentence, a definition paragraph for *touched*, the derivation sentence, and the "today's real edges" line (landing a task file re-runs `triage`; `CHANGELOG.md` and `.gitignore` feed nothing). The no-op row now says a landing or an amendment can be that row too.
- The § 3 landing bullet now says *touched* and states that a landing can put a file into 3c's set while the regeneration still comes after it. The land-before-rewrite ordering and its reason are unchanged.
- The § 4 `regenerated` bucket now reads *touched*.
- Layer parity: `skills/new-project/LAYER.md` § *Ordering*'s pointer to 3c now reads "created, landed or amended after its consumer". `LAYER.md` is the file both front doors read, and `new-project` itself never lands or amends, so its share of the rule is the ordering it already follows.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills) and pins that the links resolve: a contract pin, not evidence. The two cold drills in the Human test plan are the evidence and have not been run.

**Judgement calls.**
- *Touched* is defined by what changed, not by which act changed it. The task rejected "created or landed" as a second trigger word, and a definition by effect keeps the set derived as the layer grows.
- An owner verb's amendment (*brought up to date*) is **covered**, not excluded. It changes the content a generated file may be computed from, and excluding it would recreate this defect one step out, as the Context predicted.

**Respec.** `project-baseline`: the requirement *Generated files invalidated by the adoption are regenerated by their owners* now says *touched*, and two scenarios were added (landing a task file regenerates the dashboard; landing a `.gitignore` regenerates nothing and says nothing). The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-323 because a landing that leaves a generated file stale with no step to regenerate it is a silent wrong result (keys 1, 3) and the fix is one rule in one step with no open design question (key 4), while TASK-323 carries an undecided ordering question; key 6 inert — both candidates sit in correctness-invariants or have no theme
- step 3 — verified: held. adopt-project SKILL.md § 3c triggers on "creates" and derives its set from "what this run actually created"; landing a present, uncommitted task file creates nothing, so the set is empty while tasks/README.md is stale. The step-3 bullet (line 224) restates the same "created" scope. LAYER.md § Ordering points at 3c for "an artifact created after its consumer" — the parity site
- step 4 — layer: local (skills/adopt-project, skills/new-project/LAYER.md)
- step 5 — fix in skills/adopt-project/SKILL.md (§ 3 landing bullet, § 3c, § 4 bucket), skills/new-project/LAYER.md (§ Ordering pointer); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh link resolution; evidence = the two Human test plan drills, not run
- step 7 — respecced project-baseline; requirements changed: Generated files invalidated by the adoption are regenerated by their owners (+2 scenarios); intended anyway — TASK-100's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-05 — **Human test plan — cold drills, passed on the second run.** Fixtures `%LOCALAPPDATA%/Temp/d100a` and `d100b`, built by a script: a repo carrying every LAYER.md row (agent guide rendered from the seed with the universal conventions spliced, BRIEF, architecture, an empty features index, spec map `coverage: not-applicable`, tasks with an epic, story and two todo tasks, a generated dashboard, CHANGELOG, `.gitignore`, `.gitattributes`, `.editorconfig`, a proprietary LICENSE). Skills copied: adopt-project, new-project, tasks, feature, specs, roll-changelog, populate-tests, domain, verify-conventions, roadmap. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. The brief (shared drill preamble and closing asks; no expected outcome stated) was "Run /adopt-project against repo/. If the instructions offer to land (commit) files that are present but uncommitted, accept that offer for every path it lists. Answer no other question. Give its full report." Accepting the landing is necessary, since unattended it is not taken and 3c is never reached; it reveals that the offer exists, not what follows it. **The first run is not counted.** The fixture omitted `roadmap`, so triage could not render and the runner reported the dashboard unregenerated, correctly. Its hand-written config and spec map lacked fields that `/tasks init` and `/specs init` then added (touches of their own), and a `done` task with no code drew a defect filing. The second run used the inits' reconciled config and map as baseline, TASK-001 at `todo`, and `roadmap` copied. **Coldness:** neither run listed skills. → `verify` → **done**.
