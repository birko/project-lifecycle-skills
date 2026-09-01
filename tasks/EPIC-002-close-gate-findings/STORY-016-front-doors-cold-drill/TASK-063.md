---
id: TASK-063
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: fix-next
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-3]
pr: null
github-issue: null
jira-key: null
---

# The upgrade path's headline case has no state and no remedy

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance).

`adopt-project`'s own description bills it as *"the UPGRADE path — re-run it whenever the universal layer
grows, to reconcile a repo that adopted an older version."* The artifact the layer grows fastest is the
**agent guide**. That case currently falls between two stools.

**Measured on `Birko/Consumers/WorkoutTracker`**, adopted 2026-08-18: its `CLAUDE.md` is 342 lines with
all four `##` sections present, and it is a demonstrably older vintage —

- its close gate names `/code-review` **only**; `/verify-conventions` is absent, which is the one skill
  adoption exists to feed;
- no **task-first gate**;
- no *generated files are owned by their verbs* and no *status changes go through their verbs* rules.

Neither available answer fits:

| Candidate | Why it does not apply |
|---|---|
| `present, outdated` | `LAYER.md:122` makes it claimable *"only where something can tell you — a row whose already present? column names a verb, whose delta then is the evidence."* No verb owns the guide's shape. Its parenthetical fallback is scoped to *"an agent guide missing a section"* — this guide is missing none; the staleness is **inside** a section. |
| The row's remedy, *"merge by section — add missing `##` sections"* | There are no missing sections to add. |

So the drill did what the rule told it to — reported `present` with the gap enumerated — and the flagship
upgrade scenario landed as a hand-written paragraph under a table, discoverable only by whoever reads
that one report.

**Why the honest answer might be "the rule is right and the advertising is wrong."** `LAYER.md`'s
distinction is real: reading a schema back from an owner and judging someone's prose are different acts,
and the second is a content audit the layer deliberately refuses. That is a legitimate resolution — but
then `adopt-project`'s description should not promise an upgrade path for the artifact it cannot
reconcile. Deciding which way to cut is this task; **do not assume a new state is the answer.**

**Adjacent, not duplicate: TASK-024** (*"the other owner verbs still cannot say whether an artifact is
current"*) is about verbs that exist and cannot answer. This is about a row where **no verb exists to
ask**. Cross-reference both ways; if the resolutions turn out to be one change, say so and merge them
explicitly rather than silently.

## Acceptance criteria

- [x] The stale-vintage-guide case has **one** documented outcome: a state, an explicit content-audit hand-off, or a stated limitation — chosen deliberately, with the reason recorded
- [x] If the resolution is a limitation, `adopt-project`'s **description** stops promising to reconcile what it cannot, so the advertising matches the behaviour
- [x] Whatever is chosen holds for the measured WorkoutTracker case: every `##` section present, three working rules absent, `/verify-conventions` missing from the close gate
- [x] `present, outdated`'s "claim it only where something can tell you" guard is left intact — this must not become a licence to judge prose
- [x] TASK-024 is cross-referenced, with a line on whether the two are one change or two
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Actually amending WorkoutTracker's guide — that is **TASK-059**'s reconciliation run, and it is the consumer of whatever this task decides.
- Teaching the other owner verbs to reconcile — **TASK-024**.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

*Amended 2026-09-01, **before** the drill ran. The first two items were written expecting a new survey
state, and the resolution is a **limitation**: item 1 asked that the staleness "land in a named outcome",
which is precisely what the fix declines to do, and item 2's negative control is moot because with nothing
to trip, no guide can trip it. **Item 2 had also been ticked in error** — on a measurement produced by the
approach that was subsequently rejected, using four probes I chose myself rather than the seed's eight.
Amending a **test plan** to match a settled resolution is legitimate; rewriting an **acceptance criterion**
after the fact is not, and criterion 1 already admitted "a stated limitation" as one of its three outcomes.*

- [x] Run `adopt-project`'s survey against `Birko/Consumers/WorkoutTracker` — every `##` section present, four named rules absent — and confirm the run reports the guide `present`, **invents no state for the vintage**, and does not leave the gap as free prose under the table
- [x] Repeat against `Birko/Consumers/Symbio`, a 239 KB Slovak rulebook with its own 40 `KRITICKE` sections, and confirm it is **not** reported as lacking the seed's rules — the case the limitation exists for
- [x] Confirm the run tells the reader *why* the vintage is not assessed, rather than silently omitting it — a limitation nobody is told about is indistinguishable from an oversight
- [x] Read `adopt-project`'s description against what the run actually did, and confirm they agree

## Implementation plan

1. Establish whether a non-prose-judging delta exists for the guide. **It does not** — see the Outcome's
   three measurements. This step is the task.
2. State the limitation in `LAYER.md` (a section plus a clause on the guide row).
3. Correct `adopt-project`'s description so the upgrade promise is scoped to shape.
4. Cross-reference TASK-024 with the verdict on one-change-or-two.
5. `skills-lint` + `skills-lint-test`.

## Outcome

**What the fix was: a stated limitation, and an advertisement corrected to match it.** `adopt-project`
billed itself as *"the UPGRADE path — re-run it whenever the universal layer grows"*, and the artifact the
layer grows fastest is the agent guide. A guide with every `##` section present but an older vintage of the
rules inside surveyed as `present`, so the flagship upgrade case reported nothing. The survey now says
plainly that it reconciles the layer's **shape** and does not judge whether the prose inside a hand-written
document is current — in a new § *A guide's vintage is not surveyable*, in the guide row, and in the
skill's own description.

**The task predicted this answer and I dismissed it.** Its Context said *"the honest answer might be 'the
rule is right and the advertising is wrong'"*, and warned **do not assume a new state is the answer**. I
built a third option instead — diffing the guide against the seed's named rule list, on the grounds that
list membership is not prose judgement — and the gate demolished it. Three measurements, all reproducible:

| Attempted rule-list diff | Result |
|---|---|
| Is it a check for the shape we would have made? | **Yes** — `Symbio`'s guide is 239 KB of Slovak with **40 `KRITICKE` sections and 345 mentions of tasks**, and the test reports it missing four English rules and offers to append them |
| Does the negative control survive? | **No** — this repo's own `AGENTS.md`, the guide the human test plan uses to prove a current guide is not flagged, omits two of the seed's named items |
| Is the inventory reproducible? | **No** — the seed's `### Working rules` carries **eight** bullets plus the skills its close gate names; my own two measurements both said "four", picked by me |

That last one is the tell: the state's own test is *could you write the missing items down as a list before
looking at the repo?* — and I could not, twice, while asserting I had.

**Step-6 split.** There is no fix-dependent automated test; the change is a stated limitation. What exists:
`skills-lint` OK (18 skills) and 43/43 lint-test cases, both **contract pins, not evidence** — neither reads
this prose. The real evidence is the three measurements above, which are reproducible from the repos named,
and the fact that the rejected alternative *fails* two of them.

**Judgement calls, and why the stricter option was rejected.**

- **Rejected: a new survey state.** It needs a delta over named things, and the only named inventory
  available is the seed's — which is our shape, not the repo's. A repo stating the same rule in its own
  words is the normal case.
- **Rejected: a content-audit hand-off to a verb.** Nothing owns the question. `/verify-conventions` reads
  a guide as the source of truth rather than auditing it; `/domain`'s cross-reference pass audits a
  glossary against code. Inventing an auditor for someone's rulebook is a much larger decision than this
  task, and it would still be judging prose.
- **What a reader gets instead**, and it is not nothing: [[verify-conventions]] lints real diffs against
  whatever the guide records, so a rule a project never adopted surfaces the moment code contradicts it —
  judged against **that project's** rulebook rather than ours.
- **TASK-024 is two tasks, not one, and 063 did not narrow it.** An earlier draft of that cross-reference
  claimed it had; that claim depended on the loosened owner definition, which was reverted. The bar for
  `present, outdated` is unchanged. What survives is the distinction 063 paid for: **an owner may answer
  where it wrote the shape itself, and must not where a human wrote the content** — every row TASK-024
  covers is the first kind, which is why this limitation does not reach them.

**Flagged, not fixed:** nothing. `docs/specs/.map.yml` here still carries `areas: []`, so step 7's respec
could not run — **TASK-079** owns it.

## Drill outcome — 2026-09-01: PASSED

A cold survey drill ran `adopt-project` step 1, read-only, against `WorkoutTracker` (a guide with every
`##` section and four named rules absent) and `Symbio` (a 239 KB Slovak rulebook with 40 `KRITICKE`
sections of its own). The brief never used the words *vintage*, *stale* or *limitation*.

**The question that decides whether a stated limitation is honest, and its answer:**

> *"Do you know whether each guide is up to date? If not, say whether the instructions **explained why
> not**, or simply **left it unaddressed** — and whether you noticed the difference."*

> **"No, and the instructions explain why in so many words rather than leaving a silent gap… I noticed the
> difference (I can *see* WorkoutTracker's guide predates several current conventions, and Symbio's uses a
> wholly different structure) but the skill explicitly instructs me not to certify currency from that
> observation, and I didn't."**

That is the whole test. A limitation nobody is told about is indistinguishable from the oversight this task
started as; the runner was told, understood why, and could still see the staleness it was declining to
grade.

**Symbio is the case the limitation exists for, and it held.** Guide reported `present`; the absent English
section names were **not** flagged. In the runner's words: *"I did not run the check the passage says is
wrong to run."* The rejected approach would have offered to append four English rules to that file.

**The advertising matches.** Asked to read the `description:` against its own run, the drill found the one
clause added by this task — *"it does NOT judge whether the prose inside a hand-written document is still
current"* — and reported it as *"precisely the boundary I hit and honored on the agent-guide row."*

**It also independently exercised TASK-061's conditional rows**, which had only ever been drilled once:
`WorkoutTracker` `.env.example` **missing** on real evidence (`Reps__Seed__Enabled` documented in
`Program.cs`), `Symbio` `LICENSE` **not applicable** (README: *Proprietary — Birko s.r.o.*), `Dockerfile`
**present, elsewhere** (`deploy/Dockerfile`).

**Three findings, none of them this task's to fix:**

- The survey cannot say whether a run is a **first adoption or a re-run**, though both repos' briefs say so
  and the skill advertises both as use cases → **TASK-090**.
- `present, elsewhere` on a conditional row, and a guide **split across companion files**, are both
  undefined → **TASK-091**.
- `tasks/: present` reads as *done* — **third** drill to land on that cell; recorded on **TASK-024**, which
  owns it.

## Progress log

- step 2 - picked; ranked above TASK-035 on key 1: adopt-project's description promises an UPGRADE path, and the artifact the layer grows fastest (the agent guide) has no state and no remedy, so a stale one reports `present`. A promise the front door cannot keep beats a question nobody owns, though both are silent front-door defects. Key 6 degenerate. Picked with the user available, since the resolution is a genuine fork.
- step 3 — verified: HOLDS. WorkoutTracker re-measured 2026-09-01 — 342 lines, all four `##` sections present, four named rules absent.
- step 4 — layer: local.
- step 5 — FIRST ATTEMPT (rejected): loosened `present, outdated` to accept a template's named rule list as a delta source, so the guide row could report a vintage.
- step 5b — correctness rejected that attempt on three measurements: it is a check for the shape we would have made (Symbio: 40 KRITICKE sections, 345 task mentions, reported missing four English rules), the negative control fails (this repo's own AGENTS.md omits two seed items), and the inventory is not reproducible (8 bullets, my measurements both said 4). Also found a contradiction (never touch a section's content vs offer to add rules), no fill path for a non-verb owner, and a stale pointer. REVERTED the whole attempt.
- step 5 (second) — implemented the limitation the task itself predicted: a § *A guide's vintage is not surveyable* section, a clause on the guide row, and a scoped upgrade promise in the description. Lint OK (18 skills), 43/43.
- step 6 — no fix-dependent test exists (a stated limitation). Lint + 43 cases are contract pins, NOT evidence; the evidence is the three measurements, and that the rejected alternative fails two of them.
- step 5d — 3 boundaries, 0 spawned. TASK-024's cross-reference corrected: it had recorded 063 as resolved on the reverted approach.
- step 7 — respec skipped: `areas: []` (TASK-079).
- step 8 — parked at REVIEW: two drill steps in the human test plan are real and unrun.
- 2026-09-01 drill — PASSED. WorkoutTracker + Symbio, read-only, brief withheld the words vintage/stale/limitation. Runner: "the instructions explain why in so many words rather than leaving a silent gap", and it noticed the staleness it was declining to grade. Symbio's guide NOT flagged for missing English sections — "I did not run the check the passage says is wrong to run." Description clause confirmed as the boundary it honoured.
- Spawned TASK-090 (first adoption vs re-run is invisible) and TASK-091 (present-elsewhere on a conditional row; a split agent guide). Third corroboration of the `tasks/: present` cell recorded on TASK-024.
- status review -> done.
