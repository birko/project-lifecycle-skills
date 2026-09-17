---
id: TASK-110
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-4]
pr: null
github-issue: null
jira-key: null
---

# The scaffolder still gates two conditional rows on a kind list the inventory replaced with a question

## Context

**From a [[code-review]] pass on 2026-09-08.**

`AGENTS.md` § Conventions requires that **"a row's condition and its creator must agree"** — the same
change that adds a conditional row fixes the scaffolder line that contradicts it. `LAYER.md:32-33`
states both conditions as questions **about the artifact**, explicitly not as project kinds:

> *"does anything here require an environment variable to run?"* · *"is anything here deployed as a
> running service?"*

`skills/new-project/SKILL.md:93` and `:141` (and the layout tree at `:23`) still gate both on a **kind
list** — `service / API / web / worker`. Line 93's parenthetical even claims *"the row in LAYER.md is
the one both now match"*, which is false as written.

### The concrete divergence

A repo of kind `other` — or the **desktop app** kind `LAYER.md` itself notes the intake enum does not
offer — that reads runtime config from the environment gets **no `.env.example` from `new-project`**,
while [[adopt-project]] walking the same row reports it `missing`. The two front doors disagree about
the same repo, which is the exact failure layer parity exists to prevent.

**This is the rule catching its own author:** the convention was written in this epic, and the
scaffolder line it names was never brought into line.

## Acceptance criteria

- [x] `new-project` decides both rows by the artifact question `LAYER.md` states, not by a kind list
- [x] Kind remains usable as **evidence** toward the answer, never as the answer — matching
      `LAYER.md` § *Conditional rows* and the precedence rule that a declared kind outranks an inferred one
- [x] The false parenthetical at `:93` is corrected or removed, not left asserting agreement that does
      not exist — **removed**, since the agreement it claimed is the thing that was missing
- [x] The layout tree at `:23` agrees with whatever the rows now say — both tree lines rewritten, plus a
      comment line so a reader scanning only the tree is told the rows ask about the repo, not its kind
- [x] Both front doors produce the same verdict for the same repo — demonstrated on a kind the enum
      does not offer, since that is the case that exposed it. **Drilled 2026-09-17** with two independent
      cold runners; both reached the same verdict. See `## Drill record`
- [x] `bash .github/workflows/skills-lint.sh` passes — green, 18 skills, exit 0

## Out of scope

- **Adding a `desktop app` kind to the intake enum.** `LAYER.md` deliberately decides rows by artifact
  question precisely so the enum does not have to be exhaustive; extending it is a separate argument.
- Any conditional row other than `.env.example` and `Dockerfile`.
- The `(lazy)` rows — a different marker with different rules.

## Human test plan

- [x] Run `new-project` for a repo that reads runtime config from the environment but is not any of
      `service / API / web / worker`, then run `adopt-project` over the result. Expected: both agree.
      Today the scaffolder creates nothing and the adopter reports `missing`. **Run 2026-09-17 — they agree.**

## Outcome

**What the fix was.** `new-project` decided whether a repo gets a `.env.example` and a `Dockerfile` by
checking the project's *kind* against a list — `service / API / web / worker`. `LAYER.md`, the shared
inventory both front doors are supposed to read, had already replaced that with a question about the repo
itself (*does anything here require an environment variable to run?*, *is anything here deployed as a
running service?*). So a desktop app or a repo of kind `other` that genuinely needs env config got no
template from the scaffolder, while `adopt-project` — walking the same row correctly — reported it
`missing`. The two front doors disagreed about one repo, silently. All four scaffolder sites now read the
condition off the row, and kind is demoted to evidence toward the answer.

**The step-6 split.** Bidirectional assertion, **7** sites × 2 halves, HEAD vs working tree:
**kind-gated 7/7 → 0/7; asks-the-row 0/7 → 7/7; exit 1 → 0.** Fix-dependent: `tree/.env.example`,
`tree/Dockerfile`, `bullet/.env.example`, `bullet/Dockerfile`, `LAYER/condition-claim`, and — added after
the close gate found them — `LAYER/row:.env.example` and `LAYER/row:Dockerfile`. Contract pins,
**not evidence**: the 47 `skills-lint-test.sh` cases and `skills-lint.sh` — green either way, and they
would stay green with this change absent.

**Judgement calls, and why the stricter option was rejected.**

- **Fixed `LAYER.md` too, though the task named only the scaffolder.** The stricter reading was to fix the
  four cited sites and spawn the inventory sentence. Rejected: `LAYER.md:128-129` asserted *"`.env.example`
  and `Dockerfile` turn on the project kind"* — it is the sentence the scaffolder was obeying. Fixing the
  creator while leaving the inventory licensing the defect means the next author re-derives the kind list
  from the file they are told to match. Same function, same root cause, so step 3's pack rule applies.
- **Did not touch `adopt-project`, and checked rather than assumed.** Layer parity is a hard rule, so the
  reflex is to edit both. `adopt-project/SKILL.md:62-72` already reads each condition off its row and
  explicitly refuses to keep a local list of which rows are conditional — so the parity obligation is
  discharged by the shared inventory plus the creator. Editing it would have added a restated list.
- **Wrote the two new ask-steps with question text and an answer-less path.** The lighter option was
  "ask the user" and move on. That is precisely the defect TASK-127 closed one commit earlier, so shipping
  it here would have re-opened a convention while fixing a different one. Both now carry the question
  verbatim and resolve an unanswered run to `unknown` + a report line, never to a silent skip — a silent
  skip reads as a settled `not applicable`, which is the gap-laundering `LAYER.md` warns about.
- **AC5 is desk-walked, not drilled, and is left unticked.** Walked for a *desktop app + CLI + core
  library* that requires a runtime env var — a kind the intake enum does not offer. `new-project` now
  reaches the row's question, answers Yes, and writes the template; `adopt-project` walks the same row,
  finds the condition holds and the file absent, and reports `missing`. Both doors agree the artifact
  belongs; for `Dockerfile` on the same repo both agree it does not. That is a reading of the prose by
  someone holding the change — the weakest form of evidence this repo accepts — so the box stays `[~]`
  and the cold drill in `## Human test plan` is the real test. **It is unrun: it needs a runner that has
  not seen this change and whose context does not already hold these skills, and every agent on this
  machine holds them (installed at user level).** That is why this closes at `review`, not `done`.

**Flagged but not fixed.**

- **`docs/specs/` has no bodies**, so step 7 respecced nothing — owned by TASK-080, already filed.
- **AGENTS.md § Commands calls install-root drift "check 4"; the lint prints it as check 5** (check 4 is
  cross-skill flags). Confirmed while running the lint. Already owned by **TASK-081** — *"One number now
  names two different lint checks"* — so not folded in.
- **The step-6 assertion is not installed as a CI check**, deliberately, on TASK-127's precedent: a
  hard-coded site list would pass a new site silently — as it nearly did here — and a general "gates on
  kind" detector is prose-shaped. Recorded here rather than left as an implied gap.
- **The `reads` vs `requires` split in the condition's wording** → spawned as **TASK-136**. Three sites
  (`AGENTS.md:291`, `adopt-project/SKILL.md:77`, and one `LAYER.md` paragraph) still say *reads* where
  `LAYER.md:206` settled *requires*. A different defect from this one — this task fixed how the condition
  is *decided*, that one fixes what it *says* — and pre-existing, so folded out rather than in.

## Progress log

- step 2 — picked; ranked above TASK-089 (`coverage: unverified` never produced) because that task's acceptance is open-ended research needing a cold runner and explicitly permits "no honest case constructible" as an outcome, so it fails key 4 (self-containment) — it cannot finish inside one session. Key 6 (theme) was inert: all eight STORYs in EPIC-002/EPIC-003 declare `theme: correctness-invariants`. TASK-130 (the only P1) was excluded at step 1 — its AC1 is a decision that needs the user.
- step 3 — verified: **held, and wider than filed.** All three cited sites confirmed at `skills/new-project/SKILL.md:23`, `:33`, `:93`, `:141` (the layout tree carries the kind list twice, once per artifact, so the task's ":23" is two sites). The parenthetical at `:93` is false as stated — `LAYER.md:32-33` state both conditions as questions about the artifact, not kind lists. **Pack member pulled in, same root cause, same file's owner:** `LAYER.md:128-129` itself asserts *"`.env.example` and `Dockerfile` turn on the project kind"*, contradicting its own rows at `:32-33` **and** its own § *Ask the artifact's own question, not "what kind is this repo"* at `:178+`. That sentence is what authorised the scaffolder's kind list, so fixing the creator without it leaves the inventory still licensing the defect. Not spawned — same function, same cause. **`adopt-project` needs no change** and was checked rather than assumed: `SKILL.md:62-72` reads the condition off the row and explicitly refuses to keep a local list of which rows are conditional, so layer parity is satisfied by the shared inventory (`LAYER.md`) plus the creator.
- step 4 — layer: local. Root cause is in this repo's own `skills/new-project/`; nothing upstream is involved.
- step 5 — fix in `skills/new-project/SKILL.md` (4 sites: layout tree `.env.example` + `Dockerfile`, and the two creation bullets) and `skills/new-project/LAYER.md` (§ *Conditional rows* opening claim). No code, so the "tests" are the step-6 assertion plus `bash .github/workflows/skills-lint.sh` — **green, 18 skills, exit 0**. Root cause fixed rather than the symptom: the task named four scaffolder sites, but the inventory sentence at `LAYER.md:128-129` is what *authorised* them, so patching only the creator would have left the next author re-deriving the same kind list from the file they are told to match. **Two ask-steps were added and given their question text and answer-less path in the same edit** — § Output/prose rules requires both halves, and an ask-step written without them would have shipped the defect TASK-127 closed one commit earlier.
- step 6 — bidirectional assertion (populate-tests § *Prove the guard can fail*, third form) over 5 decision sites × 2 independent halves, scored in a detached worktree at HEAD vs the working tree: **kind-gated 5/5 → 0/5, asks-the-row 0/5 → 5/5, exit 1 → 0.** Fix-dependent = all 5 sites by name: `tree/.env.example`, `tree/Dockerfile`, `bullet/.env.example`, `bullet/Dockerfile`, `LAYER/condition-claim`. Contract pins, **not evidence**: all 47 `skills-lint-test.sh` cases and `skills-lint.sh` itself — green before and after, and they would stay green with this change absent; they pin frontmatter, links, file refs and flag contracts, none of which this change touches. **The assertion twice caught its own detector**, which is the guard behaving as a guard: scoring site 5 on the kind *enum* missed the old claim (phrased "turn on the project kind", not as a list) and then fired on the **fixed** text, because the postmortem I wrote quotes the old list and the old claim verbatim. Both halves had to be rescored on the *claim* with `*"…"*` spans stripped — quoting a defect is not asserting it. A detector that cannot tell a rule from its own postmortem would have scored this repo's most careful prose as the defect. **Not installed as a CI check, deliberately**, on TASK-127's precedent: it carries a hard-coded list of 5 sites, so a sixth added tomorrow passes it silently — the restated-list defect this repo lints for elsewhere — and a general detector for "this sentence gates on kind" is prose-shaped, carrying the false-positive profile AGENTS.md measured and rejected at 24:0. The durable guard is the reviewer plus the `## Human test plan` drill, which is **unrun**.
- step 7 — respecced: nothing to respec, flagged rather than skipped. The map is usable and the right area resolves — `project-baseline` → `skills/new-project/**` + `skills/adopt-project/**` covers both changed files — but `docs/specs/` still holds only `.map.yml`; no spec body has ever been generated, because TASK-080 (the first full harvest) is `todo`. Generating one here would be TASK-080's job and its diff would read "everything new", carrying no evidence for this fix. Requirements changed: none.
- step 8 — 5b gate, **three axes reported side by side, not merged**. **standards** ([[verify-conventions]]): rulebook = AGENTS.md § Conventions via the CLAUDE.md @import bridge, ladder rung 1; project extension **none found**; 3 of 3 changed files linted, 0 excluded. One ⚠ — this task has no `## Implementation plan`, against § Working rules *"Plan before implementing"*; **not backfilled** (a plan written after the work is a transcript) and the skill gap behind it is already filed as TASK-135. One 💡 — the router grew 188→193 lines vs *"Router SKILL.md files stay small"*; judged acceptable and recorded rather than passed silently (`new-project` has no `verbs/` tree to move detail into, and 193 is the low end of its siblings at 181–402; the growth is the ask-step question text § Output/prose rules **requires**). **Layer parity checked, not assumed**: the change does not extend the layer — no row added, removed or re-conditioned — and it touches `LAYER.md`, which is the rule's own test; editing `adopt-project` would have *added* the restated list § Code structure forbids. Register-on-introduce: nothing new to record — the rule enforced here (*"a row's condition and its creator must agree"*) is already in § Conventions. **fidelity** ([[verify-intent]]): intent = this task's 6 criteria; `feature: null` so no ledger; **baseline unavailable and said so** — area `project-baseline` maps both files but no spec body exists. Criteria 1,2,3,4,6 built; **criterion 5 unverifiable from the diff** (it needs a run, not prose) and left `[~]`; one 💡 scope note — the `LAYER.md` edit is named by no criterion, reported rather than hidden, and not spawned because criterion 1 is otherwise unsatisfiable (it requires deciding by "the artifact question LAYER.md states" while that file stated the opposite). Nothing out of scope built; all three Out-of-scope bullets held. **correctness** ([[code-review]] medium): **five findings, four fixed in-scope, one spawned.** (1) the new absolute claim was contradicted by the two rows' own cells 20 lines up — *"No — a library, a CLI, a desktop app — → not applicable"* — so a CLI requiring an API key hit the same two-answers disagreement *from inside the row*; **this is the best finding of the run** and the guard was extended to cover those cells. (2) the `.env.example` decision sat in step 3 while manifests are written in step 5, and `LAYER.md`'s *"a repo with no components answers no"* rule would have settled every greenfield repo `not applicable`, so the new ask could never fire — fixed with the same after-the-scaffolder ordering note the CI bullet already carries. (3) "report the row `unknown`" named a surface `new-project` does not have (survey states are the adopter's) while the adjacent CI bullet says *don't announce it here* — fixed by adding the step-6 checklist line both bullets now defer to. (4) *"Not sure yet"* was offered as an answer and left undefined — fixed: it lands in `unknown`, not No. (5) the `reads`/`requires` wording split → **TASK-136**, a different defect, pre-existing. **security-review** not applicable — the diff is markdown skill prose about which files a scaffolder creates; no auth, data-access, input-handling, crypto, secrets, dependency or endpoint surface. 5c skipped — `integration: single-branch`. 5d sweep: 3 bullets, all **boundaries** (deliberate limits with reasons), 0 spawned from the sweep; 1 spawned earlier in the run — TASK-136.
- step 8 — closed **review**; 94e4010 (work). Trailer note: the commit was written **without** a `Co-Authored-By:` line — AGENTS.md § Working rules and [[tasks]] § Conventions both forbid it, and a repo rule outranks the harness default. Steps 6-9 of `close` skipped per the review-park path (`integration: single-branch`, and a task at `review` must not close a remote); step 10 ran — dashboard regenerated, parents checked and already correct (STORY-012 and EPIC-002 both `in-progress` with open children, so no rollup edit).

## Drill record — 2026-09-17

**Two runners, one repo, opposite directions**, because the defect was a *disagreement* and one reader
cannot exhibit one. Neither brief mentioned `.env.example`, `Dockerfile`, project kinds, or the word
*agree*; each runner got only the instruction files and was asked to report the artifacts/states it
reached and why.

**Runners.** `claude -p --disable-slash-commands` (Claude Code 2.1.274), cwd
`…\Temp\claude\drills-133906\d110a` and `\d110b` — throwaway directories with no `CLAUDE.md` or
`AGENTS.md` above them, each holding only its own brief, its own fixture and its **own copy** of the
instruction files, so neither could see the other's material.

**Coldness — confirmed, both channels.** A pre-flight probe from the same root returned **`NONE LOADED`**
and did not know the subject's vocabulary. Each runner's §1 reported no guide, no skills, no memory index.
Scan: neither report uses a subject term the supplied instruction files did not contain. *(A first round
was void — the runners were pointed at the installed skills by path and all were refused at the sandbox
boundary. Every one of them refused to reconstruct the instructions from plausibility and reported the
blocker instead. An author's setup defect, not a finding; the copies fixed it.)*

**Fixture — `Notely`**, a compound *desktop app + CLI + core library* requiring `NOTELY_DB` at runtime,
with no default. Deliberately **a kind the intake enum does not offer**, which is the case that exposed
the defect. Not this repo and not Birko, per § *The cold drill*'s fixture rule.

**Result: PASS — the two doors agree, on both rows.**

| | `.env.example` | `Dockerfile` |
|---|---|---|
| **`new-project`** (greenfield, paper run) | **create it** — *"the conditional row resolves Yes"* | **not applicable**, settled |
| **`adopt-project`** (same repo, survey) | **missing** — *"Yes, the condition holds"* | **not applicable**, settled |

Both cited the row's own question and the *requires* test; **neither used a kind list**. The adopter
evidenced it from source — `Db.cs` throws when `NOTELY_DB` is unset — rather than from the label.

**Two of this task's own fixes were exercised by name, which is the part a desk-walk could not have given:**
- The **ordering caveat** (added after the close-gate review) did work the runner would otherwise have got
  wrong: *"Read at step 3, `LAYER.md` § A repo with no components of its own answers no would have settled
  every greenfield project `not applicable` and the ask would never fire… Notely would have lost its
  `.env.example` at the one moment the user was present."*
- **Kind demoted to evidence** was named as the thing that prevented the original defect: *"what stopped
  `.env.example` being skipped because 'desktop apps don't need one'."*

**One finding, filed as [[TASK-138]]:** the rows say what settles **Yes** and never what settles **No**.
The runner reached the right No and flagged it as the one judgement it could not point at a sentence for —
adding that a wrong No is invisible, since `not applicable` earns no checklist line. Not a failure of this
task; the gap it stood next to.
