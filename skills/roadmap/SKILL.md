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

If neither tree exists, print one line: `No tasks/ or docs/features/ in this project.` and exit.

## Cross-tree pass (shared engine)

The canonical collection + divergence routine. **Other skills delegate here.** Single
enumerate-read-join-diff pass; batch the Reads.

### 1. Collect tasks
Run the [[tasks]] skill's [Collection pass](../tasks/SKILL.md#collection-pass) — gives
counts/buckets, `byParent`, and each task's `parent`, `status`, `findings:`, and `feature:` link,
plus each epic's optional `kind:`.
**Only for STORYs under an epic with `kind: review-intake`**, also count unticked `- [ ]` lines in
the STORY body — DV12 needs them, and no other rule does, so don't scan bodies anywhere else.

### 2. Collect features
Glob `docs/features/FEATURE-*/`. For each folder read:
- `idea.md` frontmatter `status:` (**coarse marker** — exactly one of `idea | review | done | dropped | superseded`) and the `# Heading` title.
- `decisions.md` table → count rows by `State` (`proposed | approved | changed | deferred | removed`).
- `status.md` `**Phase:**` line (**derived display** — one of `idea | prototyping | deciding | building | review | done`, or the terminal mirrors `dropped | superseded` copied from the coarse marker for killed/re-homed features).
- The `## Prototype` line in `idea.md` (recorded decision: Built / Skipped / N/A / Pending).

Also read `docs/features/README.md` if present — its table maps each feature to a `Source`
epic (a back-up for the join when task back-links are missing).

### 2b. Collect specs (only if `docs/specs/.map.yml` exists with a non-empty `areas:` list)
Read `.map.yml` (area list) and each `docs/specs/<area>.md` frontmatter: `area`,
`generated-at`, `sources`, `source-commits` (absent ⇒ no external baselines), `shaped-by`, `shaped-by-derived` (absent ⇒ `false`), `shaped-by-unresolved` (absent ⇒ unknown). Compute staleness exactly as the [[specs]] skill's
`verify` verb defines it (`git diff --name-only <generated-at>..HEAD -- <sources>`;
unknown sha or missing spec file = stale/never-generated). **Sources globbing outside this
repo are resolved against their own repo via `source-commits`, per that verb's § External
sources** — do not skip them and do not diff them here: `generated-at` measures only this
repo, so in a polyrepo aggregator every cross-repo area otherwise reports fresh forever and
DV7 becomes decorative. An external source with no `source-commits` entry is **unknown
baseline**, which DV7 reports as stale — never as fresh. Don't re-derive spec semantics
beyond that — generation and the staleness definition live in [[specs]]; this engine only
consumes them for the drift audit. When the map is **absent or still the empty scaffold seed
(`areas: []` — what [[new-project]] writes at birth)**, skip the collection — but if the
project has real code (a `src/` tree or a build manifest with tracked source files), flag
DV10 instead of staying silent: the spec layer is missing, not merely unconfigured. An empty
map must never be collected as a "working" spec layer with zero areas.

### 3. Join feature ↔ tasks ↔ epic
- **Primary join:** tasks carrying `feature: FEATURE-NNN` → that feature. Compute `tasksDone / tasksTotal`.
- **Slug fallback:** if a feature has no back-linked tasks, match its slug against STORY/EPIC slugs (e.g. `FEATURE-017-kobold-endpoint` ↔ `STORY-015-kobold-endpoint`). A fallback-only join is a divergence (DV3) **only when the slug-matched story/epic has tasks** — those tasks should carry the `feature:` back-link and don't. A zero-task pairing (scaffold-seeded `idea` stub ↔ `planned` story stub, awaiting decompose) is the healthy pre-decompose state, not drift.
- **Epic mapping:** feature → owning EPIC via its tasks' `parent` chain, else the README `Source` column.

### 4. Divergence rules (the canonical set)
Flag a feature (or task) when:

| ID | Condition | The drift it catches |
|----|-----------|----------------------|
| **DV1** | Feature phase `idea` / all decisions `proposed`, but ≥1 linked task is `in-progress`/`done` | Feature docs frozen while work moved on (FEATURE-019 pre-fix) |
| **DV2** | All linked tasks `done` (≥1 exists) but feature coarse `status` ≠ `done` and phase ∉ {`done`,`review`} | Shipped work never closed out on the feature side (FEATURE-016 pre-fix) |
| **DV3** | A task whose story/epic slug-matches a feature has `feature:` null/missing | Broken back-link — feature can't see its own work |
| **DV4** | Feature has linked tasks but every decision is still `proposed` | Tasks exist that no `approved`/`changed` decision generated |
| **DV5** | Feature with no matching epic/story/tasks (and not a shipped `done` backfill), **or** a story/epic with tasks but no feature folder | A requirement tracked in only one tree |
| **DV6** | `idea.md status` ∉ the coarse set, or `status.md` phase ∉ the derived set | Invalid/stale marker (the `in-progress` phase we hit on FEATURE-016) |
| **DV7** | A spec's `sources` changed since its baseline — `generated-at` for in-repo sources, the matching `source-commits` entry for each external repo — or a mapped area was never generated, or an external source has no baseline at all (from step 2b) | Stale behavioral map — code moved on, the spec is lying. **Report which repo drifted**, not just a total: in an aggregator the answer is usually a sibling, and "3 changed" without a repo name sends the reader to the wrong tree. An external source with no `source-commits` entry is reported as *unknown baseline* rather than fresh — the whole failure this rule exists to catch is a check that cannot fire quietly passing |
| **DV8** | Feature coarse `status: done` with ≥1 linked task, but no spec lists it in `shaped-by` (only when `docs/specs/.map.yml` exists) — **suppressed** when the feature's `decisions.md` History log contains a `no spec surface` line (the [[feature]] review carve-out for genuinely docs-only/internal features), and **not raised at all against specs whose provenance was never derived** (see DV11) | A shipped feature whose behavioral change never landed in the specs — **advisory**: the fix path is `/specs regen --feature FEATURE-NNN`, whose diff review settles it either way. **Report the area's `shaped-by-unresolved` count alongside the finding whenever it is non-zero** — `derived: true` is not a completeness claim, and a miss computed from a fraction of the trail is a weaker signal than one computed from all of it. Say which it is; don't let the reader assume the strong version. **A high count is often the project's commit trail, not its work**: regen refuses a commit that only *mentions* a task, and a task whose state says the work never landed ([[specs]] regen step 5a), so on a repo whose commits don't name tasks in their subjects most tasks resolve to nothing and this rule's miss is unproven either way |
| **DV11** | A spec's `shaped-by-derived:` is `false` or absent (only when `docs/specs/.map.yml` exists) | Provenance was **never computed** for that area, so its `shaped-by: []` is unknown, not empty. Report it as its own finding and **suppress DV8 against those areas** — otherwise an unfilled field is indistinguishable from a genuine landing miss, and the audit reports a feature gap that is really a generator gap. Measured on Symbio 2026-08-01: all 31 areas carried `shaped-by: []` because `regen --all` resolved no `--feature` flag and, before that release, only flagged runs wrote the field at all. Fix: re-run `/specs regen <area>`, which now derives it |
| **DV9** | A task carries `feature: FEATURE-NNN` but no decision row in that feature's `decisions.md` lists it in the `→ Tasks` column | The ledger doesn't know about its own work — one of the three backfills (`/tasks new` step 10b, `/tasks spawn` step 6, `/feature decompose` step 4) was missed; fix by writing the ID into the owning decision's row. **Expect the inherited case**: a task created under an existing parent picks up its `feature:` without passing through any of the three, which is why this rule is an audit and not a redundancy — `new` step 10b now triggers on the link rather than on `--from-feature`, but only at creation time |
| **DV10** | The project has real code (a `src/` tree or build manifest with tracked sources) but no `docs/specs/.map.yml` — **or the map's `areas:` list is empty** (the [[new-project]] scaffold seed that was never filled) | The whole spec layer is silently absent — every spec check (story-close regen offer, DV7/DV8, `/feature review`'s spec-landing gate) skips when the map is missing/empty, so nothing else will ever surface this — **advisory**: run `/specs init` to bootstrap |
| **DV12** | Under an EPIC stamped `kind: review-intake`, a STORY carries unticked checklist lines in its body but has **no open TASK** (all children `done`/`cancelled`, or none exist) | Findings filed but never scheduled. Only `status: todo` tasks are ranked by `pick`, the `Next up` snapshot, or [[fix-next]] — a finding left as a checklist bullet is invisible to all three, so the review reads as drained while part of it was never worked. Fix by decomposing the remaining lines with [`/tasks intake --epic`](../tasks/verbs/intake.md) or `/tasks new` |

### 5. Output model
Return `{ tasks: <collection>, features: [{ id, title, epic, coarseStatus, phase,
decisions:{proposed,approved,changed,deferred,removed}, tasksDone, tasksTotal, backlinkOk,
divergences:[DVx…] }], specs: [{ area, generatedAt, stale, shapedBy, shapedByDerived, shapedByUnresolved }] | null,
divergences:[{id, target, rule, detail}] }`. Renderers consume this;
they do not re-derive it.

## Render — full `/roadmap`

From the output model:

1. **Lead with verification debt.** Any feature in phase `review` (built, sign-off pending) is listed first as outstanding work — before `building`/`idea` ones — mirroring the [[feature]] skill's "verification debt surfaces first" rule.
2. **Group by epic**, newest-active first; skip fully-`done`/`cancelled` epics into a collapsed tail. Per feature line:
   ```
   EPIC-012 Backend consolidation — in-progress (8/24 tasks)
     FEATURE-019 OAuth/identity      building  2/7   ✓ synced
     FEATURE-017 /kobold endpoint    building  0/5   ✓ synced
     FEATURE-016 Retire old stack    done      2/2   ✓ synced
     FEATURE-031 …                   idea      0/1   ⚠ DV4 tasks exist, decisions proposed
   ```
   Sync mark: `✓ synced` if no divergence, else `⚠ DV<n> <short reason>`.
3. **Divergence audit** at the bottom — one line per finding with the rule id and the concrete fix path:
   ```
   Divergences (2):
     FEATURE-031  DV4  tasks decomposed but D1–D2 still proposed → run /feature decide FEATURE-031
     specs/auth-session  DV7  stale — 3 sources changed since a1b2c3d → run /specs regen auth-session
   ```
   If none: `Divergences: none — the two trees agree.`
4. **Untracked** — list DV5 items (one tree only) under a "Tracked in one tree only" heading; these are the real planning holes.
5. Read-only. For `--fix`, append a "Proposed reconciliation" block (the edits), but apply nothing.

## Render — compact slice (for the [[tasks]] snapshot)

When [[tasks]] calls this engine for its bare-`/tasks` snapshot, it renders only:
```
features/  <F> features · idea <i> · prototyping <p> · deciding <de> · building <b> · review <r> · done <d>
  ⚠ divergence (<n>): <FEATURE-NNN DV<x>>, …      [or:  ✓ in sync]
  specs: <n> stale                                [omit when docs/specs/ absent or all fresh]
Run /roadmap for the full epic→feature→task view.
```
Enumerate **all** phases but **omit zero-count buckets** (same suppress-zeros rule as the tasks snapshot), appending `dropped <x>` / `superseded <x>` when non-zero, so every feature lands in exactly one bucket and the counts sum to `<F>`. Lead the line with any `review`-phase feature count (verification debt).

## Conventions

- **Read-only, stdout-only.** Never writes `docs/ROADMAP.md` — `/roadmap` is on-demand. Static `docs/ROADMAP.md` (seeded by `new-project`) is a hand-maintained coverage map, not this skill's output. Persistent drift signal lives in `tasks/README.md` via `tasks triage`.
- Project-root/shape detection matches the [[tasks]] skill.
- Stakeholder-facing language in feature columns; `TASK-NNN`/`EPIC-NNN` ids are fine.

## Related skills

- [[tasks]] — dev-facing tree; its snapshot renders the compact slice of this engine.
- [[feature]] — stakeholder-facing tree; bare `/feature` and `status` verb delegate collection here.
- [[specs]] — harvested behavioral map; owns generation + staleness. Spec drift → `/specs regen`.
- [[handoff]] — same legibility principle at conversation scope.
