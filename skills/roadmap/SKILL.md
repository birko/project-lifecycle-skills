---
name: roadmap
description: Unified cross-tree view of the dev-facing tasks/ tree and the stakeholder-facing docs/features/ tree, joined by epic, with a divergence audit that flags when the two have drifted out of sync. Use when the user says "/roadmap", "show the roadmap", "what's planned" (across both features and tasks), "are features and tasks in sync", "check for drift", "divergence check", "feature/task sync", "cross-tree status", "prehľad roadmapy", or wants the full epic→feature→task picture rather than just one tree. This skill OWNS the shared "Cross-tree pass" (collection + divergence rules) that the [[tasks]] status snapshot and [[feature]] listing both delegate to — keep the engine here, render slices elsewhere.
---

# roadmap

A read-only, unified view over the project's **two planning trees**:

- **`tasks/`** — dev-facing Epics → Stories → Tasks (the [[tasks]] skill).
- **`docs/features/`** — stakeholder-facing feature lifecycle (the [[feature]] skill).

They answer the same question — "what's planned / what's next / where do we stand" — for
different audiences, and they **drift** if nobody cross-checks them (a feature reads
`idea` while its tasks shipped; a task carries `feature: null` though its feature is
decided). This skill joins them by epic and **audits the drift**.

> **This skill owns the Cross-tree pass.** The [[tasks]] status snapshot renders a
> compact slice of it; bare `/feature` delegates to it too. Never re-implement the
> join/divergence logic elsewhere. One engine, many renderers.

## Verbs / args

Invoked as `/roadmap [args]`:

- `/roadmap` — full render (default): every epic with its features and per-feature sync state, then the divergence audit.
- `/roadmap --check` — divergence audit only (skip the full tree); fastest "are we in sync?" answer.
- `/roadmap EPIC-NNN` — scope the render to one epic.
- `/roadmap --fix` — after the audit, *propose* the concrete reconciliation edits (does not apply them; hand off to [[tasks]] / [[feature]] `decide` to action). Never auto-edits — drift fixes are judgment calls (e.g. approving decisions, flipping a feature to `done`).
- `/roadmap --across` — render every sibling project of a polyrepo, not just this repo. Passed straight
  through to [[tasks]]' [Collection pass](../tasks/SKILL.md#collection-pass) step 1b, which owns the
  declared root, the one-level bound and the `<repo>/TASK-NNN` id qualification — **read it there; do not
  restate the walk here.** Each sibling's `docs/features/` joins to that sibling's own tasks only:
  **the cross-tree join is per repo, and never across two.** A feature in one project and a task in
  another are not a pair, and treating them as one would manufacture divergence findings out of two
  unrelated trees.
  **A project with `docs/features/` and no `tasks/` still renders here**, unlike in [[tasks]]' own
  across-mode: this skill's contract is *both* trees, and its single-repo path already handles a repo with
  only one of them. So widen the participation probe to `tasks/` **or** `docs/features/` for this verb —
  a features-only project is invisible otherwise, which is the drift a roadmap exists to catch.
  **`--fix` is refused together with `--across`**, for the reason [`audit`](../tasks/verbs/audit.md) gives
  for the same pair: its proposals are edits, and across-mode is read-only.
  **An epic scope under `--across` names its repo**, because epic ids collide between siblings the same way
  task ids do. Take `<repo>/EPIC-NNN` and scope the render to that repo's epic. A bare `EPIC-NNN` is resolved
  against every participating project, recomputed each run:
  - exactly one has it → scope to that one, and print `scope: <repo>/EPIC-NNN` so the reader sees which;
  - several have it → render nothing and print
    `EPIC-NNN is ambiguous across projects: <repo>/EPIC-NNN, … — pass one of these.`;
  - none has it → print `EPIC-NNN is not in any participating project.` and render nothing.

  Never pick one of several by the invoking repo or by order. Two runs from different folders would then scope
  differently with nothing to say so.

If neither tree exists, print one line: `No tasks/ or docs/features/ in this project.` and exit. **Under
`--across` the line is about the whole set**, not this repo: a project with neither tree is simply not
participating. So this repo having neither, while a sibling has one, renders the siblings. Only when no
participating project has either tree, print `No tasks/ or docs/features/ in any project under <root>.` and
exit. Where `siblings.root` is undeclared or does not resolve, [[tasks]] step 1b's line comes first and the run
is single-repo, so the single-repo line applies.

## Cross-tree pass (shared engine)

The canonical collection + divergence routine. **Other skills delegate here.** Single
enumerate-read-join-diff pass; batch the Reads.

### 1. Collect tasks
Run the [[tasks]] skill's [Collection pass](../tasks/SKILL.md#collection-pass) — gives
counts/buckets, `byParent`, and each task's `parent`, `status`, `findings:`, and `feature:` link,
plus each epic's optional `kind:`. Every rule below reads a task's status **in both forms**, as [[tasks]]
§ *Lifecycle* → *Reading a task's status* defines them: `verify` reads as `review`, and a `blocked:` field
leaves the task in the state its `status:` names. **The flag alone is never a divergence**: a blocked task
is judged by its state, like any other.
**Only for STORYs under an epic with `kind: review-intake`**, also count unticked `- [ ]` lines in
the STORY body — DV12 needs them, and no other rule does, so don't scan bodies anywhere else.

### 2. Collect features
Glob `docs/features/FEATURE-*/`. For each folder read:
- `idea.md` frontmatter `status:` (**coarse marker** — exactly one of `idea | review | done | dropped | superseded`) and the `# Heading` title.
- `decisions.md` table → count rows by `State` (`proposed | approved | changed | deferred | removed`).
- `status.md` `**Phase:**` line (**derived display** — one of `idea | prototyping | deciding | building | review | done`, or the terminal mirrors `dropped | superseded` copied from the coarse marker for killed/re-homed features). **Absent file ⇒ no phase**: record `phase: null`,
  never `idea.md`'s coarse marker, which reads `idea` through every healthy build; DV1 reports the absence.

Also read `docs/features/README.md` if present — its table maps each feature to a `Source`
epic (a back-up for the join when task back-links are missing).

### 2b. Collect specs (only if `docs/specs/.map.yml` exists with a non-empty `areas:` list)
Read `.map.yml` (area list) and each `docs/specs/<area>.md` frontmatter: `area`,
`generated-at`, `sources`, `source-commits` (absent ⇒ no external baselines), `shaped-by`, `shaped-by-derived` (absent ⇒ `false`), `shaped-by-unresolved` (absent ⇒ unknown). Compute staleness exactly as the [[specs]] skill's
`verify` verb defines it (§ *Staleness definition (canonical)*), **including its in-repo anchor**, which is not
`generated-at` alone: a spec committed after its stamp is measured from its own commit. Diffing from the stamp reports
every spec respecced in the same commit as its sources as stale, and a drift note where most entries are false gets read
past. Unknown sha or missing spec file = stale/never-generated. **Sources globbing outside this
repo are resolved against their own repo via `source-commits`, per that verb's § External
sources** — do not skip them and do not diff them here: the in-repo anchor measures only this
repo, so in a polyrepo aggregator every cross-repo area otherwise reports fresh forever and
DV7 becomes decorative. An external source with no `source-commits` entry is **unknown
baseline**, which DV7 reports as stale — never as fresh. Don't re-derive spec semantics
beyond that — generation and the staleness definition live in [[specs]]; this engine only
consumes them for the drift audit. When the map is **absent or still the empty scaffold seed
(`areas: []` — what [[new-project]] writes at birth)**, skip the collection — but evaluate
DV10 instead of staying silent (§ *DV10: what counts as code* decides whether the repo has
behaviour to spec): the spec layer may be missing, not merely unconfigured. An empty
map must never be collected as a "working" spec layer with zero areas.

### 3. Join feature ↔ tasks ↔ epic
- **Primary join:** tasks carrying `feature: FEATURE-NNN` → that feature. Compute `tasksDone / tasksTotal`.
- **Slug fallback:** if a feature has no back-linked tasks, match its slug against STORY/EPIC slugs (e.g. `FEATURE-017-kobold-endpoint` ↔ `STORY-015-kobold-endpoint`). A fallback-only join is a divergence (DV3) **only when the slug-matched story/epic has tasks** — those tasks should carry the `feature:` back-link and don't. A zero-task pairing (scaffold-seeded `idea` stub ↔ `planned` story stub, awaiting decompose) is the healthy pre-decompose state, not drift.
- **Epic mapping:** feature → owning EPIC via its tasks' `parent` chain, else the README `Source` column.

### 4. Divergence rules (the canonical set)
Flag a feature (or task) when:

| ID | Condition | The drift it catches |
|----|-----------|----------------------|
| **DV1** | ≥1 linked task is `in-progress`/`done`, and the stored phase reads `idea` or there is no `status.md` (the coarse marker never stands in). **Not reported when DV4 fires on the same feature**: DV4's fix, `/feature decide`, chains `/feature status`, which clears this too | Rollup frozen while work moved on (FEATURE-019 pre-fix). With no `status.md` the detail reads `no rollup — run /feature status FEATURE-NNN`: every `/feature new` opens this window. The old "all decisions `proposed`" arm was DV4's condition, so it was removed |
| **DV2** | All linked tasks `done` (≥1 exists) but feature coarse `status` ≠ `done` and phase ∉ {`done`,`review`} (**DV2 is not evaluated at all when there is no `status.md`**: the phase it judges does not exist yet, DV1 reports the feature, and the `/feature status` that clears DV1 derives the phase DV2 then reads) — **except** when an `approved` or `changed` row is not decomposed (its `→ Tasks` cell is empty, or names a task not on disk: [[feature]] `pick`'s gate D) | Shipped work never closed out on the feature side (FEATURE-016 pre-fix). The exception is work not filed yet, such as a `changed` decision on a signed-off feature whose change is not built: its phase is `building`, the feature's own decompose offer covers it, and nothing has shipped that could be closed out |
| **DV3** | A task whose story/epic slug-matches a feature has `feature:` null/missing | Broken back-link — feature can't see its own work |
| **DV4** | Feature has ≥1 linked task that is not `cancelled`, and no `approved` or `changed` row, which includes a ledger with no rows or only the template's placeholder | Tasks exist that no `approved`/`changed` decision generated |
| **DV5** | Feature with no matching epic/story/tasks (and not a shipped `done` backfill), **or** a story/epic with tasks but no feature folder — **except defect work, read from declared fields**: an epic stamped `kind: review-intake` and everything under it, and a story or epic whose every task carries a non-empty `findings:` list | A requirement tracked in only one tree. **Fix path:** `/feature new` for the work, or accept it in the item's own file (§ 4b) when the one-tree tracking is intended. **Defect work has no feature by design**: a finding is a defect in behaviour some feature or rulebook already owns, not a new requirement, so reporting it here buries the real holes under correct structure. Nothing else needs a marker: chores and tree hygiene stay in `tasks/_loose/`, which this arm never sees (a loose task has no story or epic), and any other story or epic with tasks is planned work that should trace to a feature. Never exempt a story by its title |
| **DV6** | `idea.md status` ∉ the coarse set, or `status.md` exists and its phase ∉ the derived set. An absent `status.md` is not DV6: DV1 reports it, and only when work has moved | Invalid/stale marker (the `in-progress` phase we hit on FEATURE-016) |
| **DV7** | A spec's `sources` changed since its baseline — `/specs verify`'s in-repo anchor for in-repo sources (step 2b), the matching `source-commits` entry for each external repo — or a mapped area was never generated, or an external source has no baseline at all (from step 2b) | Stale behavioral map — code moved on, the spec is lying. **Report which repo drifted**, not just a total: in an aggregator the answer is usually a sibling, and "3 changed" without a repo name sends the reader to the wrong tree. An external source with no `source-commits` entry is reported as *unknown baseline* rather than fresh — the whole failure this rule exists to catch is a check that cannot fire quietly passing |
| **DV8** | Feature coarse `status: done` with ≥1 linked task, but no spec lists it in `shaped-by` (only when `docs/specs/.map.yml` exists) — **accepted** (§ 4b) when the feature's `decisions.md` History log contains a `no spec surface` line (the [[feature]] review carve-out for genuinely docs-only/internal features, and § 4b's older spelling of `accepted divergence DV8`), and **not raised at all against specs whose provenance was never derived** (see DV11) | A shipped feature whose behavioral change never landed in the specs — **advisory**: the fix path is `/specs regen --feature FEATURE-NNN`, whose diff review settles it either way. **Report the area's `shaped-by-unresolved` count alongside the finding whenever it is non-zero** — `derived: true` is not a completeness claim, and a miss computed from a fraction of the trail is a weaker signal than one computed from all of it. Say which it is; don't let the reader assume the strong version. **A high count is often the project's commit trail, not its work**: regen refuses a commit that only *mentions* a task, and a task whose state says the work never landed ([[specs]] regen step 5a), so on a repo whose commits don't name tasks in their subjects most tasks resolve to nothing and this rule's miss is unproven either way |
| **DV9** | A task carries `feature: FEATURE-NNN` but no decision row in that feature's `decisions.md` lists it in the `→ Tasks` column | The ledger doesn't know about its own work — one of the three backfills (`/tasks new` step 10b, `/tasks spawn` step 6, `/feature decompose` step 4) was missed; fix by writing the ID into the owning decision's row. **Expect the inherited case**: a task created under an existing parent picks up its `feature:` without passing through any of the three, which is why this rule is an audit and not a redundancy — `new` step 10b now triggers on the link rather than on `--from-feature`, but only at creation time |
| **DV10** | The repo has behaviour to spec — established by § *DV10: what counts as code* — but no `docs/specs/.map.yml`, **or the map's `areas:` list is empty** (the [[new-project]] scaffold seed that was never filled) and the map does not declare `coverage: not-applicable` | The whole spec layer is silently absent — every spec check (story-close regen offer, DV7/DV8, `/feature review`'s spec-landing gate) skips when the map is missing/empty, so nothing else will ever surface this — **advisory**: run `/specs init` to bootstrap |
| **DV11** | A spec's `shaped-by-derived:` is `false` or absent (only when `docs/specs/.map.yml` exists) | Provenance was **never computed** for that area, so its `shaped-by: []` is unknown, not empty. Report it as its own finding and **suppress DV8 against those areas** — otherwise an unfilled field is indistinguishable from a genuine landing miss, and the audit reports a feature gap that is really a generator gap. Measured on Symbio 2026-08-01: all 31 areas carried `shaped-by: []` because `regen --all` resolved no `--feature` flag and, before that release, only flagged runs wrote the field at all. Fix: re-run `/specs regen <area>`, which now derives it |
| **DV12** | Under an EPIC stamped `kind: review-intake`, a STORY carries unticked checklist lines in its body but has **no open TASK** (all children `done`/`cancelled`, or none exist) | Findings filed but never scheduled. Only `status: todo` tasks are ranked by `pick`, the `Next up` snapshot, or [[fix-next]] — a finding left as a checklist bullet is invisible to all three, so the review reads as drained while part of it was never worked. Fix by decomposing the remaining lines with [`/tasks intake --epic`](../tasks/verbs/intake.md) or `/tasks new` |

### 4b. Accepted divergences

A rule can fire on an arrangement somebody chose: a repo that is task-only on purpose trips DV5 on every epic. Left
alone, the warning is always present and stops being read, so it devalues the real ones beside it. Skipped silently,
it cannot be told from a check that never ran. So a finding can be **accepted**: recorded once, with a reason and a
date, **in the flagged item's own hand-edited file**, never in a generated one.

| Target | Where the acceptance is written |
|---|---|
| an epic, story or task | its frontmatter: `accepted-divergence: ["DV5 2026-11-13 — task-only on purpose; stakeholder work is not tracked here"]`, one string per accepted rule, as `DV<x> <date> — <reason>` |
| a feature | a History line in its `decisions.md` containing `accepted divergence DV<x> — <reason>`. **`no spec surface` is DV8's older spelling of the same thing**, and is read as `accepted divergence DV8` |
| a spec area or the map | not acceptable. Their fix is a regen or `/specs init`, which costs less than recording a reason |

- **An acceptance covers one rule on one target, and an epic's covers the stories under it.** Accepting DV5 on
  EPIC-001 suppresses DV5 on EPIC-001 and its stories, nothing on EPIC-010, and nothing but DV5. The epic scope
  matches the reach of DV5's own defect exemption ("an epic … and everything under it"), and spares a task-only repo
  a line per story. A story can carry its own acceptance where its epic has none. A new epic in the same task-only repo gets its own line, which is the point: each one is a fresh
  decision.
- **An accepted finding is suppressed from every warning** ([[tasks]] `triage`'s callout and the compact slice), and
  **still listed** by the full render and `--check`, with its reason and date, so the audit stays complete.
- **An acceptance whose rule no longer fires is reported** as `accepted DV<x> on <target> no longer fires — remove
  the line`, so a stale reason does not outlive the arrangement it explained.
- **The outcome of a check is one of three, and `--check` prints it as its first line:** `in sync`;
  `in sync — <n> accepted`; or `<n> open divergences`, singular for exactly 1 (`1 open divergence`). The full render's `Divergences …` block and the `Accepted`
  block follow it.

### 5. Output model
Return `{ tasks: <collection>, features: [{ id, title, epic, coarseStatus, phase (null when `status.md` is absent),
decisions:{proposed,approved,changed,deferred,removed}, tasksDone, tasksTotal, backlinkOk,
divergences:[DVx…] }], specs: [{ area, generatedAt, stale, shapedBy, shapedByDerived, shapedByUnresolved }] | null,
divergences:[{id, target, rule, detail, accepted: {date, reason} | null}] }`. Renderers consume this;
they do not re-derive it.

### DV10: what counts as code

**Do not ask for a `src/` tree or a build manifest.** Both are artifacts of compiled and packaged
projects, and DV10's whole job is to notice a spec layer that went missing quietly — so a detector that
only recognises one shape of project fails silently on every other. **Measured on this repo:**
`docs/specs/.map.yml` sat at `areas: []` from 2026-08-18 to 2026-09-01 — every skill in the set
unspecified, for two weeks — and DV10 never fired once, because the source is `skills/**/*.md` and there is no
`src/` and no manifest. The check that exists to catch a silently-absent spec layer was itself silently
absent, on the repo that ships it.

**Ask the repo what its source is, in this order, and stop at the first that answers:**

1. **The spec map's own `ignore:` list**, where a map exists — tracked files it does not exclude. A project
   that has already told the spec layer what its source is should not have to tell `roadmap` again, and
   this is the same declaration-over-inference rule the rest of the set runs on.
2. **What the repo's own gate runs over**, where there is one — a CI workflow or task-runner target names
   its inputs. This is [[adopt-project]]'s test-harness move applied here: the sibling blind spot in
   `LAYER.md` was fixed by asking what the gate actually executes rather than adding another glob, and the
   same generalisation is what makes this rule portable.
3. **A `src/` tree or a build manifest** — the original test, kept last rather than deleted, so a
   conventional project behaves exactly as before.
4. **Nothing answered ⇒ no finding, and one line saying the check could not decide.** An undetermined repo is not a
   finding, so it is never in the divergence list, the compact slice or `triage`'s callout. The full render and
   `--check` print, after the divergence and accepted blocks:
   `Not checked: DV10 — nothing here says what the source is (no spec map, no gate inputs, no src/ or manifest); /specs init settles it`.
   Without it a run that could not decide reads the same as one that found the spec layer in order. Firing here is what would make DV10 ignorable: a notes vault, an ADR archive or a fresh
   scaffold carrying nothing but the layer would each get a permanent false gap, and a check that cries
   wolf on correct repos is worth what an unrun one is.

**`coverage: not-applicable` on the map ends it before any of that.** That verdict is `/specs init`'s own
statement that it looked and found no behavioural code — a declaration, from the verb that owns the
question. DV10 must not re-litigate it.

**Why the ladder ends in silence rather than a guess.** Steps 1-3 are all *declarations* the repo made
about itself; step 4 is the absence of one. Inferring "this markdown is behaviour" from markdown alone
cannot distinguish a skill library from a notes vault, which is precisely the pair that must not collapse
— so the rule declines instead. The remedy it prints when it *does* fire is `/specs init`, which resolves
the ambiguity properly, because that verb can report `not-applicable` where DV10 can only suspect it.

## Render — full `/roadmap`

From the output model:

1. **Lead with verification debt.** Every feature the [[feature]] skill's "verification debt surfaces first" rule counts as debt is listed first as outstanding work: phase `review` (built, sign-off pending), or any linked task awaiting sign-off whatever the phase. A line with waiting tasks names their count (`building · 2 tasks awaiting sign-off`). That rule owns the set; this render applies it. A null phase never matches `review`, so only the task arm applies to a feature with no `status.md`. A feature listed here **still appears in its epic group** in step 2: this list leads with the debt, it does not move the feature out of the tree.
2. **Group by epic**, newest-active first; skip fully-`done`/`cancelled` epics into a collapsed tail. Per feature line:
   ```
   EPIC-012 Backend consolidation — in-progress (8/24 tasks)
     FEATURE-019 OAuth/identity      building  2/7   ✓ synced
     FEATURE-017 /kobold endpoint    building  0/5   ✓ synced
     FEATURE-016 Retire old stack    done      2/2   ✓ synced
     FEATURE-031 …                   idea      0/1   ⚠ DV4 tasks exist, decisions proposed
     FEATURE-032 …                   —         1/1   ⚠ DV1 no rollup
   ```
   Sync mark: `✓ synced` if no divergence, else `⚠ DV<n> <short reason>`. A feature with no `status.md` shows `—` in
   the phase column, and its audit line names `/feature status FEATURE-NNN` as the fix.
3. **Divergence audit** at the bottom — one line per finding with the rule id and the concrete fix path:
   ```
   Divergences (2):
     FEATURE-031  DV4  tasks decomposed but D1–D2 still proposed → run /feature decide FEATURE-031
     specs/auth-session  DV7  stale — 3 sources changed since a1b2c3d → run /specs regen auth-session
   ```
   If none: `Divergences: none — the two trees agree.` Accepted findings follow as their own block, never mixed into
   the open ones (§ 4b):
   ```
   Accepted (2):
     EPIC-004  DV5  2031-02-10 — internal tooling; no stakeholder-facing work to track
     EPIC-009  DV5  2031-02-10 — internal tooling; no stakeholder-facing work to track
   ```
   With no open findings and some accepted, the line reads `Divergences: none open — 2 accepted (below).`
   A DV10 the ladder could not decide adds its `Not checked` line after both blocks (§ *DV10: what counts as code*).
4. **Untracked** — list DV5 items (one tree only) under a "Tracked in one tree only" heading; these are the real planning holes.
5. Read-only. For `--fix`, append a "Proposed reconciliation" block (the edits), but apply nothing.

## Render — compact slice (for the [[tasks]] snapshot)

When [[tasks]] calls this engine for its bare-`/tasks` snapshot, it renders only:
```
features/  ⚠ sign-off <s> · <F> features · idea <i> · prototyping <p> · deciding <de> · building <b> · review <r> · done <d>
  ⚠ divergence (<n>): <target> DV<x>, …          [or:  ✓ in sync, or ✓ in sync · <a> accepted]
  specs: <n> stale                                [omit when docs/specs/ absent or all fresh]
Run /roadmap for the full epic→feature→task view.
```
Enumerate **all** phases but **omit zero-count buckets** (same suppress-zeros rule as the tasks snapshot), appending `dropped <x>` / `superseded <x>` / `no rollup <x>` (a feature with no `status.md`, so no phase) when non-zero, so every feature lands in exactly one bucket and the counts sum to `<F>`. Lead the line with the count of debt features as the [[feature]] rule defines them (`⚠ sign-off <s>`, right after
`features/`, omitted at zero). It sits outside the phase buckets, because a debt feature can be in phase `building`,
so the buckets still sum to `<F>`.

Each divergence entry is the finding's `target` from the output model, printed as the full render's audit line
prints it, then its rule id: a feature, story, epic or task id (`FEATURE-031 DV4`, `STORY-007 DV12`,
`TASK-114 DV9`), `specs/<area>` for a spec (`specs/auth-session DV7`), or `specs/.map.yml` for the map itself
(DV10). A finding is never dropped from this line because its target is not a feature. An **accepted** finding is
never on the `⚠` line; it counts only in `· <a> accepted` (§ 4b).

## Conventions

- **Read-only, stdout-only.** Never writes `docs/ROADMAP.md` — `/roadmap` is on-demand. Static `docs/ROADMAP.md` (seeded by `new-project`) is a hand-maintained coverage map, not this skill's output. Persistent drift signal lives in `tasks/README.md` via `tasks triage`.
- Project-root/shape detection matches the [[tasks]] skill.
- Stakeholder-facing language in feature columns; `TASK-NNN`/`EPIC-NNN` ids are fine.

## Related skills

- [[tasks]] — dev-facing tree; its snapshot renders the compact slice of this engine.
- [[feature]] — stakeholder-facing tree; bare `/feature` and `status` verb delegate collection here.
- [[specs]] — harvested behavioral map; owns generation + staleness. Spec drift → `/specs regen`.
- [[handoff]] — same legibility principle at conversation scope.
