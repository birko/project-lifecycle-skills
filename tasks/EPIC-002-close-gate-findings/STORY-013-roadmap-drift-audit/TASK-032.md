---
id: TASK-032
parent: STORY-013
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: [TASK-067]
findings: []
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A divergence cannot be recorded as accepted, so triage nags about a decision already made

## Context

Found while picking TASK-020 (2026-08-19) — the `pick` verb chains `triage`, whose step 8b prepends a
feature-drift callout to `tasks/README.md` whenever [[roadmap]]'s rules fire.

They fire on this repo. DV5 flags *"a story/epic with tasks but no feature folder"*, and all 30 tasks
here carry `feature: null` against zero `FEATURE-*` folders. But that is a **recorded stance**, not
drift: `docs/features/README.md` states *"the current work is deliberately task-only."* Writing the
callout would nag permanently about a decision already made, so the chained triage skipped it — which
is its own problem, because now a rule fired and nothing on disk says it was considered.

Both available behaviours are wrong:

- **Write the callout** — `tasks/README.md` carries a standing warning about an intended state. A
  warning that is always present is a warning nobody reads, which devalues the genuine ones beside it.
- **Skip it** (what happened) — indistinguishable from a `triage` that never ran the check. The next
  reader cannot tell "accepted" from "not looked at", the same collapse `unknown` vs `missing` exists
  to prevent one layer down.

The gap is that the divergence rules model only *detected / not detected*. There is no third state for
*detected and accepted*, and no place to write the acceptance — `docs/features/README.md` is a
generated file owned by `/feature status`, so the stance it currently states is not a durable record
either. Note the shape is general, not DV5's alone: any rule can fire on a deliberate arrangement.
DV8 already has a bespoke version of this (a `no spec surface` line in the ledger suppresses it), so
the pattern exists but is per-rule and undiscoverable.

### What this unblocks

**TASK-067 waits on this** (`blocks: [TASK-067]`). Its criterion 3 deletes the
`docs/features/README.md` line that the Context above quotes as this repo's "recorded stance" — so
whatever acceptance record criterion 6 here produces becomes that line's proper home, and the two
tasks should be read together even though they sit under different stories.

Concretely: this task is why criterion 6 is not circular. The stance currently lives only in a
generated file, so *recording this repo's DV5 as accepted* is both this task's own test and the
destination TASK-067 needs to exist before it can remove the original.

## Acceptance criteria

- [x] A divergence can be marked **accepted**, in a hand-editable file, with a reason and a date — never in a generated one
- [x] An accepted divergence is suppressed from `triage`'s callout and from the compact `/tasks` slice, but still **listed as accepted** by `/roadmap`, so the audit stays complete
- [x] `/roadmap --check` distinguishes three outcomes: in sync · accepted divergences only · real divergence
- [x] Acceptance is scoped to a rule **and** a target, so accepting DV5 for this repo does not blanket-suppress DV5 elsewhere
- [x] DV8's existing `no spec surface` carve-out is reconciled with the general mechanism rather than left as a second way to do the same thing
- [x] This repo's own DV5 is recorded as accepted, so a `triage` run leaves evidence the check ran
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The DV10 blind spot on prose-only repos — TASK-025 owns that.
- Adding or removing divergence rules. This is about what happens once one fires.
- Whether this repo *should* be task-only. It is, and that is not in question here.

## Human test plan

- [x] Accept this repo's DV5, run `/tasks triage`, and confirm no callout appears **and** that the acceptance is visible somewhere a reader will find it
  - **Passed 2026-11-13.**
    - `accepted-divergence: ["DV5 2026-11-13 — …"]` is in EPIC-001's and EPIC-010's frontmatter.
    - This repo's `tasks/README.md` callout became `> Feature drift: none open · 2 accepted (EPIC-001 DV5, EPIC-010
      DV5) — see /roadmap --check.`, applying the new 8b rule. The warning is gone, and the line shows the check ran.
    - The same rule run cold on `d032c`, where the only finding was accepted, wrote the same quiet line.
- [x] Run `/roadmap` and confirm the accepted divergence is still reported, marked accepted
  - **Passed 2026-11-13**, cold drill `%LOCALAPPDATA%/Temp/d032b`: a two-epic fixture, with EPIC-001 accepting DV5.
    `/roadmap --check` printed `Accepted (2): EPIC-001 DV5 2026-11-10 — internal tooling only…`, and
    `STORY-001 … (covered by EPIC-001)`.
- [x] Introduce a genuine second divergence and confirm it is *not* suppressed by the accepted one
  - **Passed 2026-11-13**, same drill: EPIC-002, with no acceptance, was reported open
    (`Divergences (1): EPIC-002 DV5 …`), and the triage callout named it alone.
  - **The first run (`d032`) found a gap, fixed before the second.** It flagged STORY-001 under the accepted
    EPIC-001 as a separate open finding. § 4b now says an epic's acceptance covers its stories, the reach DV5's own
    defect exemption has.
- [x] Confirm a DV8-suppressed feature behaves identically before and after the reconciliation
  - **Passed 2026-11-13, with one difference the criteria require.** Cold drill `%LOCALAPPDATA%/Temp/d032c`: a feature
    `done` with a linked task, a spec map, `shaped-by: []`, and a `no spec surface` History line.
    - **What is unchanged:** DV8 fired and raised no warning anywhere (no `⚠` line, no callout).
    - **The difference:** `--check` now prints `in sync — 1 accepted` and lists `FEATURE-001 DV8 2026-11-05 — no spec
      surface…` as accepted, where before it was silently absent. That listing is criterion 2's requirement ("still
      listed as accepted by `/roadmap`"), so the step's "identically" holds for warnings and, by design, not for the
      audit.

## Outcome

**The fix (the user's decision on where it lives, 2026-11-13).** A divergence can now be **accepted**: one rule on one
target, with a date and a reason, written in the flagged item's own hand-edited file, never in a generated one.
- **Where it is written:**
  - an `accepted-divergence:` frontmatter entry on an epic, story or task. An epic's entry covers its stories;
  - an `accepted divergence DV<x>` History line in a feature's `decisions.md`. DV8's `no spec surface` line is now
    read as that mechanism's older spelling, so there is one mechanism, not two;
  - spec targets cannot be accepted.
- **What accepting does:** an accepted finding leaves every warning (`triage`'s callout, the compact slice) and stays
  in every audit with its reason.
- **What `--check` prints:** its first line is `in sync`, `in sync — <n> accepted`, or `<n> open divergence(s)`.
- **When everything is accepted:** `triage` writes one quiet line, so the file shows the check ran.
- **Stale acceptances:** one whose rule no longer fires is reported for removal.
- **In this repo:** DV5 is accepted on EPIC-001 and EPIC-010, and the standing warning is gone.
- **Supporting changes:** the templates carry a commented `accepted-divergence:` line, the Collection pass reads the
  field, DV5's row names its fix path, and AGENTS.md § Conventions registers the pattern.

**Step-6 split.** Behavioural, by three cold drills:
- **`d032`:** found the story-scope gap.
- **`d032b`:** with the fix, the accepted epic and its story are listed as accepted, and the second epic is open and
  in the callout.
- **`d032c`:** a DV8 feature with `no spec surface` raises no warning and is listed as accepted.

No revert split, because the behaviour is new. Contract pins: skills-lint, and the YAML parse of both epics'
frontmatter.

**Judgement calls.**
- **In the item's own file, not a central list (the user's choice).** A deleted or renamed epic takes its acceptance
  with it, so no stale entry outlives its target. The cost is a line per epic, which is the scoping the criteria ask
  for.
- **An epic's acceptance covers its stories.** That matches DV5's own exemption scope, and a task-only repo would
  otherwise need a line per story. Found by the first drill.
- **Spec targets are not acceptable:** their fix (a regen) is cheaper than recording a reason.
- **DV8 now appears in the audit as accepted.** It used to be silently absent, and criterion 2 requires the listing.

**Close gate (inline, about 50 lines over seven files):**
- **Standards:** register-on-introduce is done (an AGENTS.md bullet pointing at the owner). The templates ship the
  field commented, per § *A template ships nothing a render cannot make true*.
- **Intent:** all seven criteria met.
- **Correctness:** two drill findings were fixed before the close: the story scope, and the `--check` outcome line
  with DV5's fix path.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Corrected 2026-11-13, after the close.** The acceptance reason first written on EPIC-001 and EPIC-010 ("this repo
is task-only on purpose … docs/features/ holds no FEATURE folders") was false. This task's Context dates from
2026-08, and the repo has had features since 2026-09-18 (FEATURE-001 to FEATURE-004). Found while picking TASK-067,
whose quoted "deliberately task-only" line had already left the index. On the user's decision:
- **EPIC-001** keeps its acceptance, with a true reason: it predates the feature tree.
- **EPIC-010's acceptance is removed**, so its DV5 warns again until someone gives it a feature or an acceptance of
  its own.

The dashboard callout shows `EPIC-010 DV5` open. The mechanism and the drills are unaffected; only this repo's record
was wrong.

**Unblocks TASK-067**, whose criterion 3 deletes the `docs/features/README.md` stance line that this acceptance
record now replaces.

**Flagged.** TASK-369, filed: DV10's undecided line and `triage`'s summary singular, raised by both `d032` runners.

## Progress log

- step 2 — picked; P2 correctness-invariants, ahead of the contract-drift P3s (key 6), and it blocks TASK-067. A check that fires permanently on a recorded stance trains readers to skip the callout (key 3, silence by habituation)
- step 3 — verified: held. This repo's dashboard carries "Feature drift (2): EPIC-001, EPIC-010 DV5" today. DV8's `no spec surface` carve-out is the one per-rule precedent
- step <guardrail> — decision put to the user (2026-11-13): an acceptance lives in the flagged item's own file (EPIC/STORY/TASK frontmatter, or the feature's decisions.md History, as DV8's note already does), not in a central list. Recommendation taken
- step 3b — planned inline after the decision (seven files): roadmap § 4b, the output model, renders and --check; triage 8b; the templates; the Collection pass field; the AGENTS.md register; this repo's acceptance
- step 4 — layer: local
- step 5 — fix in skills/roadmap/SKILL.md, skills/tasks/verbs/triage.md, skills/tasks/SKILL.md, skills/tasks/templates/EPIC.md and STORY.md, AGENTS.md; EPIC-001 and EPIC-010 accept DV5; tasks/README.md callout per the new 8b
- step 6 — behavioural: d032 (story-scope gap found), d032b (accepted plus open, correct), d032c (DV8 via `no spec surface`, accepted, no warning)
- step 7 — respecced project-roadmap (new requirement: Accepted divergences) and work-tracking (dashboard callout), restamped; project-roadmap's last source change, TASK-236, had respecced it
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
