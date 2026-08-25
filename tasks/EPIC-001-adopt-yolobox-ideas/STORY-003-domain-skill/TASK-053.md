---
id: TASK-053
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-21
depends-on: [TASK-051, TASK-052]
blocks: [TASK-056, TASK-059]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Layer parity — both front doors learn the glossary and the ADR home

## Context

`AGENTS.md` makes this a **hard rule**, not a nice-to-have:

> **Layer parity (hard rule):** any change that extends the **universal project layer** must update
> **`new-project`** *and* **`adopt-project`** in the same change. […] In practice that means editing
> **`skills/new-project/LAYER.md`**, the single inventory both skills consume — if a layer change does
> not touch that file, it is being copied somewhere instead of shared.

`domain` adds two artifacts to that layer, so both doors must know them: the scaffolder creates the layer
for new repos, the adopter reconciles it for existing ones. Extending one strands every project already
using the skills.

**The interesting half is what "seed" means for a lazily-created artifact.** Every other `LAYER.md` row
names something that always exists — a README, a CHANGELOG, a `tasks/` folder. `docs/glossary.md` and
`docs/adr/` exist **only when there is something to write** (TASK-051, TASK-052), so seeding them empty
would contradict the rule that makes them useful. The row therefore has to express *"this layer includes
a glossary, created on first real term"* rather than *"create this file"* — and the adopter's survey has
to report a legitimately-absent glossary as **not applicable yet**, distinctly from **missing**.

**The owner-verb reconcile rule applies** (`AGENTS.md`): whichever verb owns each row must answer *"is
this instance current?"*, not only *"does it exist?"*, and must report **already current** separately
from **brought up to date**. TASK-024 records that most owner verbs still cannot do this — so state which
answer these rows give rather than inheriting the gap silently.

## Acceptance criteria

- [x] `skills/new-project/LAYER.md` gains the glossary and ADR rows — the single inventory, edited once
- [x] Neither `new-project` nor `adopt-project` restates the row's content; both read `LAYER.md`
- [x] The rows express **lazy** creation: the layer includes these artifacts, and an absent one in a repo
      with nothing to record is correct, not a gap
- [x] `adopt-project`'s survey distinguishes **not applicable yet** from **missing**, so a legitimately
      absent glossary is never reported as drift — and never offered as a fill
- [x] Each row names its **Owner** verb, and that verb's answer to *"is this current?"* is stated
- [x] `new-project` does not create empty `docs/glossary.md` or `docs/adr/` at scaffold time
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The skill itself** — TASK-051 and TASK-052.
- **Backfilling this repo's owed ADRs** — TASK-054. Adoption machinery and content are separate.
- Teaching the other owner verbs to reconcile (TASK-024's scope). This task states what *these* rows
  answer; it does not fix the others.
- Retro-adopting the consumer repos — **deferred to TASK-059**. The 5d sweep reclassified this: it named a
  mechanism (whoever re-runs `adopt-project` there next), not an owner, so nothing scheduled it.
- Deferred to TASK-055 — `skills/tdd/SKILL.md:79` still says no skill creates `docs/adr/`, false since
  TASK-052. Surfaced while planning this task; a statement of fact about the skill set, not a layer row.
- Deferred to TASK-056 — `templates/CLAUDE.seed.md`'s routing table has no row for a term's meaning or a
  hard-to-reverse choice, so a scaffolded project owns both artifacts with no rule for either. Depends
  on this task; a different list from `LAYER.md`'s rows.
- Deferred to TASK-057 — four summaries that contradict the body they summarise (`fix-next:257`'s stated
  count, two `verify-intent` Related-skills lines, `docs/architecture.md:105`). Found by the close gate's
  correctness and standards passes; one group task, since the shape is the only interesting part.
- Deferred to TASK-058 — STORY-015 carries `theme: docs-i18n-coverage` over four correctness defects in the
  repo's only gate, so `fix-next` ranks them last. A re-classification, not a typo.
- Deferred to TASK-060 — ten defects the cold drill found in the surrounding skills (inventory vs
  `What it creates`, the test-harness glob ladder, `present, outdated` on the agent guide, the BRIEF skip
  contradiction, `{{ONE_LINE_PURPOSE}}`, a silent `integration:` default, and four more). Found *by* this
  task's test plan, none caused *by* this change.

## Human test plan

- [x] Run `new-project` on a throwaway repo and confirm **no** empty glossary or `docs/adr/` is created,
      while the layer report still names them as part of the layer
- [x] Run `adopt-project` on a repo with no glossary and confirm the survey says *not applicable yet*
      rather than *missing*, and offers no fill
- [x] Run it again on a repo that *does* have a glossary and confirm it reports **already current** as
      distinct from having brought it up to date
- [x] Drill the adopter on a real consumer repo (WorkoutTracker is the smallest with a live layer) and
      confirm the two new rows do not produce spurious findings

**Run 2026-08-22 as a COLD drill — all four pass.** A fresh agent was given the repo and told to *execute*
both skills as written, with this plan's **expected answers withheld**, so it reported what the prose led
it to rather than confirming a claim. That design is the point: these drills test whether a `(lazy)` marker
on a table row carries a reader to a distinct report state, and the author cannot un-know that connection.

| Drill | Evidence |
|---|---|
| 1 | Scaffolded a `library`/docs-only project: 13 files, **neither** `docs/glossary.md` nor `docs/adr/`, citing `LAYER.md:24-25` and `SKILL.md:88`. Its summary named both under *Deliberately absent* and reconstructed the rationale unprompted — *"an empty glossary would claim the vocabulary was examined and found thin"* — plus the `/domain` next-step line. |
| 2 | `Birko/Consumers/WorkoutTracker` (live layer, neither artifact): both rows assigned **not applicable yet**, marker cited, *"no offer attached — deliberately"*, and neither counted toward what the repo is missing. **The load-bearing result** — the traversal from marker to state was made by someone who had to discover it. |
| 3 | This repo (both artifacts present): both rows `present`, *"leave it, and it is current… nothing to reconcile"*, under *left alone*, with `amended: Nothing`. The distinction reads correctly; it phrased it "present and current" rather than the criterion's "already current" — semantically right, not verbatim. |
| 4 | No spurious findings against either row on the real consumer repo. Its two findings there were hand-extended generated files and a missing git remote — neither about these rows. |

**The drill also exposed ten defects in the surrounding skills** — an inventory that omits three artifacts
it creates, an evidence ladder that reports `missing` on the repo shipping it, and the upgrade path's
headline case having no state. None is caused by this change; all are filed as **TASK-060** rather than
folded in. That yield is the argument for the cold method, and TASK-060 carries the instruction to record
the method itself.

## Implementation plan

⚠ **Acceptance criteria question (AC 5):** `domain` has **no verb files** — it is a bare-noun
discipline (`skills/domain/SKILL.md` only), so the Owner cell can name nothing finer than
`[[domain]]`. And the honest reconcile answer for both rows is that **there is no shape to be
outdated**: a glossary has no template, and an ADR's parts are checked when the record is written.
So presence *is* currency here, and the only residual question is a *content* audit — which
`LAYER.md` § *Presence and shape, not content currency* explicitly puts outside adoption's remit.
The plan states that as the rows' answer. If the stronger reading was intended — adoption *offering*
`/domain`'s cold cross-reference pass as a currency check — AC 5 needs to say so, because that
crosses the presence/content line on purpose.

**Resolved 2026-08-22 — the weaker reading, deliberately.** Both rows answer *"is this current?"* with
**presence is currency**, and each states *why* (free prose has no shape to fall behind; an ADR's parts
are checked when the record is written). AC 5 stands unedited. The stronger reading was declined because
it would put adoption in the business of judging prose the repo owns, on every re-run, against
`LAYER.md` § *Presence and shape, not content currency* — whose line is *who can settle it*. The
content question is not dropped, it is `/domain`'s cross-reference pass, and the glossary row names it
as such.

### Step 1 — `LAYER.md`: define "lazy" once, as prose

New section `## Lazily-created rows`, placed after § *Delegation follows the row, not the artifact's
appearance* and before § *The adopted-repo brief*. Single home for the concept, so neither table cell
re-argues it, and a third lazy row later costs one word in the Artifact cell.

Three short paragraphs: **what the marker means** (part of the layer, *nothing* creates it — not the
scaffolder, not the adopter; the file appears on first real content, and its owner decides when);
**why**, in one clause that defers the argument to the owner rather than restating it (an empty
instance is not a neutral placeholder but a *claim* — an empty glossary says the vocabulary is settled
and thin; `[[domain]]` carries that argument, the row only has to stop both front doors seeding one);
and **the consequence for the survey**, as a forward pointer, not a copy.

The `(lazy)` marker goes in the **Artifact** cell, not buried in the *Already present?* prose — the
table is the most-skimmed thing in the file and it reads as a create-list, so a reader scanning only
the left column must see that two rows are not created.

### Step 2 — `LAYER.md`: the two table rows

Insert both **after the `docs/architecture.md` row** — keeps the three delegating trees
(`docs/features/`, `docs/specs/.map.yml`, `tasks/`) contiguous and groups the two hand-written `docs/`
artifacts together.

| Artifact | Owner | Already present? |
|---|---|---|
| `docs/glossary.md` **(lazy)** | [[domain]] | **Never create.** The layer includes a glossary; the file appears on the first term worth recording — see § *Lazily-created rows*. Absent → **not applicable yet**. Present → **leave it, and it is current**: the shape is free prose, so there is nothing an owner could find out of date. Whether its *content* still matches the code is `/domain`'s cold pass — a content audit, offered, never run by a fill. |
| `docs/adr/` **(lazy)** | [[domain]] | **Never create the directory.** It appears with its first record, and only [[domain]]'s three-part bar can justify one. Absent → **not applicable yet**: nothing observable at scaffold or adoption time can decide that a past decision *owed* a record — that is a judgement, not a probe. Present → **leave it, and it is current**: each record's parts are checked when that record is written, so there is no sweep to run and nothing to reconcile. |

Three deliberate wording choices: **"and it is current"** is the AC-5 answer stated positively (saying
only "leave it" is what would inherit TASK-024's gap silently); each cell says *why* the currency answer
is what it is, because § *Delegation follows the row* is aggressive about the opposite failure and a
reader must be able to tell these rows are not delegations without cross-referencing; and `docs/adr/`
the **directory** in the Artifact cell, since the layer contains the *home* while the record shape
belongs to `domain`.

### Step 3 — `LAYER.md`: the third survey state

One bullet in § *Detect what the repo has* → *Report the state precisely*, positioned **last, after
`missing, not offered`**, so the absence states read together and the new one is defined by contrast —
that contrast is the load-bearing part, and it is the AC-4 behaviour:

> **not applicable yet** — a **lazy** row (see § *Lazily-created rows*) with no instance, in a repo with
> nothing to record. **This is not a gap and never reported as drift.** It suppresses both the fill *and
> the offer*: asking "shall I create a glossary?" is how the empty file the lazy rule exists to prevent
> arrives with the user's consent instead of without it. **Claimable only where the row declares itself
> lazy** — an absent artifact whose row creates it is `missing`, and relabelling it here would launder a
> real gap into a design choice. Distinct from `missing, not offered`: that is a genuine gap adjudicated
> unfillable *for now*, so its offer returns when the evidence changes; this one has nothing to fill.

The "claimable only where the row declares itself lazy" clause mirrors `present, outdated`'s existing
*"claim it only where something can tell you"* guard. Putting the offer-suppression **inside** the state
definition (as `missing, not offered` already does) is what lets `adopt-project` § 3 stay untouched.

### Step 4 — `new-project/SKILL.md`: stop it creating them, and still name them

Three pointer-sized edits:

1. **Step 3**, final bullet: **`docs/glossary.md`, `docs/adr/` — create neither.** They are `LAYER.md`'s
   **lazy** rows, written by [[domain]] on first real term or record. No creation detail here because
   there is no creation — an empty one is a false claim, not a head start. This is the single invariant
   restated where it is load-bearing (AGENTS.md permits exactly that); it names no state, no owner
   behaviour and no reconcile answer, so nothing here goes wrong when the layer gains a row.
2. **The "What it creates" tree**, one comment line inside the `docs/` block:
   `# no glossary.md / adr/ — lazy rows (LAYER.md)`. A *negative* annotation earns its place because the
   tree's silence is what invites the next editor to add them "for symmetry", and this is the file's
   most-copied section.
3. **Step 6's next-step checklist**, one line: *Vocabulary & decisions: `/domain` — the layer's glossary
   and `docs/adr/` are written on first use, not scaffolded.* This is what makes the human test plan's
   "the layer report still names them as part of the layer" true.

Optional, cheap, and it makes the parity discoverable from the greenfield side: one § *Related skills*
line naming `[[domain]]` as owner of the two lazy rows.

### Step 5 — `adopt-project/SKILL.md`: two consequence bullets, no list copies

The generalized rules already absorb the new state (§ 1 defers the state list to `LAYER.md`; § 4 says a
new state that no bucket absorbs gets a bucket named after it *whether or not this page mentions it*;
§ 3 obeys the *Already present?* cell, which now says never create). So exactly two touches:

1. **§ 1 Survey**, fourth bullet under *"These consequences decide behaviour"*: **a lazy row's absence is
   not a gap** — report it as part of the layer and move on; do not fill it, do not offer to, never count
   it toward what the repo is missing. Needed because the survey's "when in doubt, `unknown` — never
   `missing`" bullet is otherwise the only absence guidance a reader of this page sees, and it points the
   wrong way for these rows.
2. **§ 4 Report**, one bullet in the per-state list: report **that it is part of the layer, and that its
   absence is correct** — never under a heading that reads as a gap, never with an offer attached. Where
   the § *Glossary candidates* pass turned up recurring nouns or suspected synonyms, they travel as a
   **finding handed to [[domain]]**, not as drift against this row: a candidate list is evidence about
   the code, not a missing artifact.

That second bullet is where AC 4's "never reported as drift" becomes checkable, and it closes the real
ambiguity — adoption *does* produce glossary input, so a reader needs telling that the input is not the row.

### Step 6 — `adopt-project/INFER.md`: retire the deferral (required, not optional)

Lines ~73–75 currently say whether the layer creates a glossary "is not settled here — that is a
`LAYER.md` row and it belongs to the change that adds it. **Don't branch on the file's existence until
then.**" This change *is* that change, so the paragraph becomes a live contradiction, and the standing
instruction two lines above it ("retire that copy the moment `docs/glossary.md` exists") stays
un-actionable until it goes.

Replace with a pointer plus the two branches, not a restatement: the layer now carries the glossary as a
**lazy** row (link `../new-project/LAYER.md`), so you may branch on existence — **present** → append
confirmed terms through [[domain]] and retire the guide-side copy per the paragraph above; **absent** →
the candidates are a finding for [[domain]] and the row is `not applicable yet`.

### Step 7 — lint and close gate

- `bash .github/workflows/skills-lint.sh`. The live hazard is check 3, which resolves relative links
  case-exactly from the file's own directory: keep every consumer-repo path (`docs/glossary.md`,
  `docs/adr/`) in **backticks**, never as a markdown link — `strip_noise` removes code spans, so
  backticked paths are invisible to the check, while a link to `docs/adr/` would resolve against
  `skills/new-project/` and fail. Any new link from `INFER.md` is `../new-project/LAYER.md`.
- No change to `skills-lint.sh`, so no new case is owed in `skills-lint-test.sh` — that rule is scoped
  to changes to the lint itself.
- Close gate: `/verify-conventions` + `/code-review` on the diff, plus the four drills on this file.
  **Register-on-introduce does not fire** — § Conventions already carries layer parity and § *The five
  records* already names both artifacts; this extends an inventory rather than introducing a pattern.

### Design tradeoff — how to express the third state

| Option | Cost |
|---|---|
| Reuse `missing, not offered` | Cheapest, and wrong. That state means a genuine gap adjudicated unfillable *for now*, whose offer returns when evidence changes — the CI section is built on that. A glossary's absence is not a gap, no evidence change makes it one, and the label still contains the word **missing**, which AC 4 forbids reporting. |
| Per-row wording on these two rows only | No new vocabulary to police, but the fill/offer suppression must then be re-derived by a reader of `adopt-project`, the next lazy artifact re-invents it, and § 4's report machinery keys on *states* — so a per-row exception has nowhere to land without a bespoke sentence. |
| **A general state + a `(lazy)` row marker** | One bullet in a list the file already declares growable, inherited by `adopt-project` with **zero list copies** because that skill deliberately refuses to enumerate states. Its hazard — a future absence mislabelled to duck a real gap — is closed by gating the state on the row's `(lazy)` marker. |

**Chosen: the general state, gated on the per-row `(lazy)` marker.** The deciding argument is copy count,
not future-proofing: `adopt-project` § 1 and § 4 both consume a state list they never restate, so a new
state costs nothing on the consumer side, whereas per-row behaviour must be described somewhere the
report can see it — a second copy, the exact thing this task exists to honour.

Secondary, and worth stating: **the reconcile answer is "there is nothing to reconcile", stated, not
implied.** Making adoption *offer* `/domain`'s cross-reference pass instead sounds stronger but breaks
§ *Presence and shape, not content currency*, which draws its line at *who can settle it* — a schema
delta is read back from an owner, a stale definition is a judgement about prose. That would put adoption
in the business of editing prose the repo owns, on every re-run.

### Risks

- **`skills/tdd/SKILL.md:79` is now false** — → deferred to TASK-055. Its trailing clause says ADRs live "where the project keeps
  them; no skill creates that directory yet" — `domain` has owned `docs/adr/` since TASK-052. STORY-003
  claimed this line, and its `[[domain]]` wikilink half **did** land; only the stale clause survives. Six
  words. Left in place, a reader of `tdd` concludes the layer has no ADR home.
- **The `new-project` "What it creates" tree is the likeliest second-copy site** — the section people
  copy when scaffolding. "The layer includes a glossary" plus a tree that omits it reads as an oversight;
  the negative annotation in Step 4 is cheap insurance.
- **`INFER.md` is the other one.** It already reasons about the glossary at length; the temptation is to
  restate the row's *Already present?* content beside the candidate-collection rules. Pointer plus the
  two-branch consequence only.
- **`templates/CLAUDE.seed.md` teaches a three-row "what gets recorded where" table** — → deferred to TASK-056 — while this repo's
  own § *The five records* has five, including the glossary and ADR rows. Consumers therefore adopt both
  artifacts with no rulebook line saying which record answers which question. A different list from
  `LAYER.md`'s rows, so not a parity violation — but it is the next thing someone fixes by pasting.
  Outside every AC here.
- **Nothing else reads `LAYER.md`** — confirmed: only `new-project/SKILL.md`, `adopt-project/SKILL.md`
  and `adopt-project/INFER.md` consume it. `README.md` and `docs/architecture.md` describe it generically
  without enumerating rows, so neither goes stale. Adding rows and a state breaks no reader.
- **Lint blind spot.** Nothing machine-checks that a row's cell is coherent, that the `(lazy)` marker
  matches the state's gate, or that `adopt-project` honours a new state. This change is reviewer-verified
  prose plus the four drills; the lint only proves links resolve.

### Splitting

**Do not split the core.** Steps 1–6 are one change by the hard rule: shipping the inventory rows without
the adopter's fill/offer suppression strands every already-adopted repo with two rows nothing knows how
to report — precisely the failure layer parity names. Step 6 is not separable either, since `INFER.md`
currently declares the question *unsettled* and is wrong the moment Step 1 lands.

The one independently *reviewable* decision is the state-vocabulary choice above — but it cannot ship
alone, having no consumer until the rows exist. Get a reviewer's eye on it first; it is not a task boundary.
