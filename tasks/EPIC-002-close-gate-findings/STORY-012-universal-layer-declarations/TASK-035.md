---
id: TASK-035
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-19
depends-on: []
blocks: []
findings: [CR-020-2, CR-020-3, DRILL-053-6]
pr: null
github-issue: null
jira-key: null
---

# Nothing owns the `integration:` question — three rules each hand it to another

## Context

Two `/code-review` findings from TASK-020's close gate (2026-08-19), in files that task's diff did not
touch. **Filed as one task, not two:** they are the same declaration falling through the same three
steps, and splitting them buries the connection that makes them cheap to fix together.

`/tasks init` must be told `integration:` when a repo's config predates the field — inferring it from
`git log` is forbidden outright, and TASK-021/023 exist because it was inferred once. But no step owns
asking:

1. **Step 1 is forbidden to find out.** `SKILL.md` § 1 says *"From outside you cannot see a version …
   Where the artifact's row names a verb, step 3's delegation is what answers, so leave the version
   question to it rather than guessing here"*, and `LAYER.md:105` only permits `present, outdated`
   once the owner verb reports a delta. The `tasks/` row names a verb, so at step 1 the fact does not
   exist yet.
2. **Step 2 is told to ask it anyway.** `SKILL.md:96` requires asking about *"a declaration a present
   artifact lacks"*, with this exact case as its worked example — knowledge step 1 was just forbidden
   to gather. So adoption either asks blindly (pestering repos that already carry the field) or the
   question migrates into step 3, breaking the **one frontier round** rule at `SKILL.md:102`.
3. **The skip path drops it entirely.** `SKILL.md:81` lets the round be *"skipped entirely"* when the
   rulebook already answers, and `SKILL.md:102` puts the inferences **and** the choices (mode,
   `integration:`, guide kind, license) in that same round. `INFER.md:112` then forbids the obvious
   repair: *"Announcing 'skipping — your rulebook answers all five' and then opening a question round
   anyway is the contradiction this paragraph exists to prevent."* On a dense-rulebook repo whose
   config lacks `integration:` — Presenter's exact shape — obeying INFER strands the question and
   re-opens the guess-from-`git log` defect.

The likely shape of the fix: the skip is scoped to **proposals**, not to the round that also carries
**declarations**, and one step is named as the owner of probing a declaration a verb will need. Do not
treat that as decided — it is the reviewer's reading and mine, not a tested one.

### Measured evidence — the greenfield half, from the 2026-08-22 cold drill (DRILL-053-6)

A cold drill of `new-project` produced a concrete instance of exactly this gap, on the **scaffold** path
rather than the adoption path:

`new-project/SKILL.md:99` chains `/tasks init mode=<mode>` and passes **no** `integration=`, so
`tasks/verbs/init.md:30` writes the template default `pr-per-task`. The drill was told to skip `git init`,
so the scaffolded repo ended up **declaring a PR-per-task policy with no git repository at all** — a
declaration nobody was asked for, in a repo where it cannot be true.

Two things this sharpens about the task:

- **`init.md:32` protects the wrong direction.** It stops an *existing* config's silence from being
  defaulted over, which is the upgrade case. A brand-new config gets the default written silently and is
  never asked — so the field this repo treats as a *declaration to read, never infer* is itself created by
  inference.
- **It confirms the "three rules each hand it to another" shape reaches past adoption.** The intake asks
  for task *mode* and not integration; step 3 delegates to the owner; the owner defaults. Whoever fixes
  ownership has to cover the scaffolder, or the same unasked declaration keeps being minted.

Filed here rather than as its own task under STORY-016 (the drill's story) because this task already owns
the question and a second task would re-litigate it — the audit duplicate rule.

## Acceptance criteria

- [x] Exactly one step owns discovering that a present artifact lacks a declaration its owner verb needs, and the other steps point at it rather than each deferring
- [x] A repo whose rulebook covers every inferable subsection **and** whose config lacks `integration:` still gets asked — once, in one round
- [x] A repo that already carries the field is **not** asked, on a first run or a re-run
- [x] The skip announcement and the question round can co-exist without contradicting `INFER.md` § *When the rulebook already answers it* — or that paragraph is amended in the same change
- [x] The one-frontier-round rule still holds: no queue of single questions, and no question migrating into step 3
- [x] Layer parity honoured if `LAYER.md` changes
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- TASK-028's separate defect in the same skip rule (counting five subsections when UI/UX is conditional). Adjacent line, different arithmetic — do them together if convenient, but its criteria are its own.
- Re-litigating the ban on inferring `integration:` from `git log`. The ban is right; this is about who asks instead.
- `/tasks init`'s own reconciliation, which TASK-023 already delivered.
- **`/tasks init`'s unreachable unattended branch, and the declined-vs-never-asked conflation in an absent `integration:` — both spawned as TASK-092** at this task's close gate. The first predates this change; the second is sharpened by it, since making absence the honest unresolved state is what gives a declination nowhere to be recorded. Neither blocks these criteria: this task owns *who asks*, TASK-092 owns *what happens when the ask returns nothing*.

## Human test plan

- [ ] Drill a repo with a dense rulebook and a config lacking `integration:`; confirm one round, one question, no `git log` inference
- [ ] Drill a repo whose config already has the field; confirm it is not asked, then re-run and confirm it is still not asked
- [ ] Confirm the skip announcement still names what covered the inferences (TASK-017's rule) in both cases

## Implementation plan

The root cause is one conflation: step 2's "round" carries **two** kinds of item, and only one of them
is the inference round's to skip.

- **Proposals** — inferred conventions. `INFER.md`'s coverage judgement governs these, and a dense
  rulebook rightly silences them.
- **Declarations** — facts that are *choices*, not observations (task mode, `integration:`, guide kind,
  licence posture). No amount of rulebook density answers one, so no coverage judgement can skip one.

And nobody owned *discovering* which declarations are absent, because step 1's "from outside you cannot
see a version" bullet swallowed the question. **A declaration and a version are not the same object:**
whether a named field is literally in a named file is as observable as whether a git remote exists;
whether an artifact matches the current template is not observable from outside at all. Step 1 already
probes the first kind of fact for four other rows.

1. **`skills/new-project/LAYER.md`** § *Delegation follows the row, not the artifact's appearance* — draw
   that line, and name step 1 as the owner of a **named** declaration's absence while the owner verb keeps
   the version question. Make the `tasks/` row name the declaration its owner needs, so the probe reads off
   the row rather than a copied list. Shared file, so layer parity is structural rather than a second edit.
2. **`skills/adopt-project/SKILL.md`** — step 1: add the declaration probe to the survey's fact list and
   narrow the version bullet so it stops swallowing declarations. Step 2: scope the skip to **proposals**,
   state that outstanding declarations always run and ride in the same one frontier round, and point at
   step 1 for how they were discovered.
3. **`skills/adopt-project/INFER.md`** § *When the rulebook already answers it* — amend the contradiction
   paragraph: the skip is over *this file's* proposals, so a round carrying only declarations is not the
   contradiction it forbids. Point at SKILL.md step 2 for the declaration list rather than copying it.
4. **`skills/new-project/SKILL.md`** — intake gains the integration model beside the task mode, and step 4's
   chain passes `integration=`. This is the greenfield arm (DRILL-053-6).
5. **`skills/tasks/verbs/init.md`** — extend the real-choice rule to the **Absent** branch: never write the
   template's `integration:` default unasked; unattended with no arg, omit the line and report unresolved,
   which is the same honest state the Present branch already produces and which a later run self-heals.
6. **`AGENTS.md` § Conventions** — extend the existing *Read the declaration, never infer it* bullet with the
   discovery half. Expanding the owning bullet rather than starting a second one.

**No lint case is added, and that is a considered no.** Check 4 pins that a *passed* `--flag` is declared by
its receiver; it cannot express "a declared arg was never passed", which is the greenfield defect's shape.
Pinning a documented probe-and-read rule is TASK-084's subject, so inventing a weaker check here would
duplicate it. The real instrument is the drill in the test plan.

## Outcome

**What the fix was.** The `integration:` policy — the one field several skills are required to *read*
rather than infer — could be created or left behind without anyone ever being asked for it, because no
step owned finding out that it was missing. Adoption's survey treated "is this field in this file" as
an artifact-*version* question and deferred it to the owner verb; the inference round was then told to
ask for knowledge it had no licence to gather; and on a repo whose rulebook already answered everything,
the round was skipped with an explicit prohibition against re-opening it. The scaffolder had the mirror
defect: it never asked, so `/tasks init` wrote its template's `pr-per-task` default as if it were a
declaration. The fix separates **declarations** (choices nobody has made) from **proposals** (conventions
read off the code), gives the survey the declaration probe, scopes the rulebook skip to proposals only,
and makes the scaffolder ask and pass the answer.

**The step-6 split.** Fixture: `C:\Source\Birko\Consumers\BardStudio`, a live consumer whose
`## Key Conventions` covers all five subsections **and** whose `tasks/.config.yml` has no `integration:`
line — the predicted configuration, found rather than built. Pre-change (`git show HEAD:`),
`adopt-project/SKILL.md` step 1 mentions "declaration" **0 times** and `INFER.md` **0 times** in the whole
file; post-change, 4 and 4. Pre-change the traversal is therefore forced to skip the question, and
`INFER.md`'s pre-existing prohibition — *"opening a question round anyway is the contradiction this
paragraph exists to prevent"* — is what forces it, which is why the split is evidence and not a
restatement of the diff. **Contract pins, not evidence:** `skills-lint` (OK, 18 skills) and
`skills-lint-test` (43/43) passed identically before and after and cannot observe this defect at any
point. **Fix-dependent tests: none.** The instrument for a prose defect is a cold reader; this session
could not spawn one, so the drill in the test plan is owed and the task ends at `review`.

**Judgement calls, and the stricter option rejected.**

- **The survey owns the probe, not the delegation.** Stricter reading: leave everything about another
  skill's file to that skill. Rejected because it is what produced the defect — the owner verb only gets
  to answer *during the fill*, which is after the one round in which the question could have been asked,
  so honouring it costs either the one-round rule or the question itself. The line drawn instead is
  observability: a named field is a grep, a template match is the owner's private knowledge.
- **An unresolved `integration:` is written as an absent field, not as the documented default.** Stricter
  option: always write a value so consumers never read a missing field. Rejected because a written default
  is indistinguishable in the file from a chosen value, and every consumer is under standing orders to read
  that field as a declaration — so the "safe" default is precisely the unreproducible inference the rule
  exists to forbid. Absent is honest, consumers already have a documented fallback, and a later adoption
  run backfills it. The template now says so in place, so the state is self-documenting wherever it lands.
- **No lint case added.** Check 4 pins that a *passed* `--flag` is declared by its receiver; it cannot
  express "a declared arg was never passed", which is the greenfield defect's shape. A presence-grep for
  the word `integration` across two skills would pass trivially and get muted. Pinning a documented
  probe-and-read rule is TASK-084's whole subject, so a weaker check here would duplicate it.
- **`AGENTS.md` extends the existing declaration bullet rather than adding a new one**, per the repo's own
  rule that a shared vocabulary keeps one owner and the owner is wherever it already lives.

**Flagged but not fixed.**

- **Two live consumer repos have no `integration:` declaration** — `BardStudio` and `Latent`, measured
  2026-09-01; both configs were written by `/tasks new`'s fallback and predate even the field's comment
  block. This change makes the next adoption pass *ask*; it does not backfill them. Not spawned as a task
  here because the work is in those repos, not this one, and `[[adopt-project]]` § 3b is explicit that a
  defect is filed into the repo it belongs to. Recorded here so the next drill on either repo knows it is
  sitting on the fixture.
- **`Presenter`, `Symbio`, `WorkoutTracker` and `Birko.Framework` all carry the field** — so the
  no-re-ask arm (criterion 3) has four real repos to check it against.
- **Two findings from this task's own close gate, spawned as TASK-092** — `/tasks init` describes
  unattended behaviour for a flag it never declares and no caller passes (pre-existing, made
  load-bearing in a second branch here), and an absent `integration:` cannot distinguish a deliberate
  declination from never having been asked, so the new probe would re-ask forever. Both were left out
  rather than folded in because each needs a design choice with consequences past this row — exactly
  what a close gate is forbidden to settle unattended.
- **One gap in this change fixed during the gate, not spawned:** the probe's report shape was
  undefined, so a reader had to invent whether an outstanding declaration was a new survey state. It
  is not — it rides on its row as `present` with the gap named, per the thin-but-present rule. A
  clarification of a sentence this change wrote, so it belonged in the change.

## Progress log

- step 2 — picked; ranked above TASK-086 because key 3 (silence): this defect writes a false `integration:` declaration with nobody asked, where TASK-086's conflation surfaces as a refusable offer. Key 4 agreed — acceptance here is determined, TASK-086 still has four live design candidates. Key 6 (theme) was inert: every candidate STORY declares `correctness-invariants`.
- step 3 — verified: held. All three deferrals confirmed at `adopt-project/SKILL.md:46-51` (step 1 defers the version question to step 3), `:124-128` (step 2 told to ask about "a declaration a present artifact lacks", with `integration:` as its worked example), `:108-114` + `INFER.md:117-126` (skip path: only glossary candidates and the 20-80% split survive a full skip, and opening a question round anyway is named a contradiction). Greenfield arm confirmed at `new-project/SKILL.md:108` — chains `/tasks init mode=… [repo=|project=]` with no `integration=`, and nothing in that skill ever resolves it — plus `tasks/verbs/init.md:30`, whose Absent branch writes the template's `integration: pr-per-task` verbatim when no caller answer arrives. **Symptom shifted since filing, defect unchanged:** `init.md:32` now asks for the field on the *Present* branch (TASK-023's delivery), so on adoption the question is no longer dropped — it fires from inside step 3's delegation, which is exactly the "migrates into step 3, breaking the one-frontier-round rule" arm the finding named as its alternative. Acceptance criteria already cover both arms and are unchanged.
- step 4 — layer: local (all four files are this repo's own skills)
- step 5 — fix in `skills/new-project/LAYER.md` (new § *A named declaration is not a version*, plus the `tasks/` row now naming `integration:`), `skills/adopt-project/SKILL.md` (step 1 probe + narrowed version bullet; step 2 skip scoped to proposals), `skills/adopt-project/INFER.md` (skip declared to be over its own proposals only), `skills/new-project/SKILL.md` (intake item 7 + `integration=` on the chain), `skills/tasks/verbs/init.md` (real-choice rule extended to the Absent branch; step 5 reports unresolved fields), `skills/tasks/templates/config.yml` (absent-means-undeclared documented), `AGENTS.md` (§ Conventions, discovery half of the declaration rule). No automated test authored — see step 6. `skills-lint` OK (18 skills); `skills-lint-test` 43/43.
- step 6 — reverted fix: prose split traced on a **real fixture**, `C:\Source\Birko\Consumers\BardStudio` — its `## Key Conventions` carries all five subsections (Build & dependencies / Code structure / Naming / UI-UX / Testing) **and** its `tasks/.config.yml` has no `integration:` line, which is exactly the configuration TASK-035 predicted. Split, mechanically confirmed from `git show HEAD:`: pre-change, `adopt-project/SKILL.md` step 1 mentions "declaration" **0 times** and `INFER.md` mentions it **0 times** in the whole file (post-change: 4 and 4). So pre-change the traversal is forced: step 1 has no probe → step 2 has no basis for "outstanding" → INFER's *unqualified* "All covered → skip the round" fires and its "opening a question round anyway is the contradiction this paragraph exists to prevent" **forbids** asking → the question either surfaces inside step 3's `/tasks init` delegation (breaking the one-frontier-round rule) or, unattended, falls out of the pass. Post-change it resolves to one round, one question. The forcing sentence is INFER's pre-existing *prohibition*, not anything this change wrote, which is what makes the split evidence rather than a restatement of the diff. Greenfield split: pre-change `new-project` intake never names the integration model and chains `mode=` alone, so `init.md:30`'s Absent branch writes the template's `pr-per-task` verbatim while `init.md:32`'s guard reads "into an existing repo" and does not apply — DRILL-053-6's exact outcome. **Contract pins, not evidence:** `skills-lint` (18 skills) and `skills-lint-test` (43/43) both passed before and after and cannot observe this defect at any point — recorded as pins so no later reader mistakes them for verification. **Fix-dependent tests: none, and the cold drill is owed and unrun** — the instrument for a prose defect is a cold reader, this session cannot spawn one, and an author's own traversal is precisely what TASK-068 records as not being evidence. Task therefore ends at `review`, not `done`.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` carries `areas: []`, so per `fix-next` step 7 there is no usable spec map; run `/specs init` (tracked as EPIC-001 / STORY-008, TASK-079). Requirements changed: none.
- step 8 — merge gate run via `/tasks close --unattended`. **Three verdicts, side by side, unmerged and unreranked** (§ *Independent review axes*): **standards ([[verify-conventions]]) — pass.** Rulebook: `AGENTS.md § Conventions` via the `CLAUDE.md` `@AGENTS.md` bridge, ladder rung 1; subsections read Framework/stack, Output/prose rules, Code structure & patterns, Naming, Testing, Keeping conventions current, Working rules, plus § Architecture. 7 files linted, 0 excluded (none generated). Layer parity satisfied structurally — `LAYER.md` plus both front doors. Register-on-introduce satisfied: the new pattern is recorded in § Conventions in this change, extending the existing declaration bullet rather than adding a competitor. § Architecture and `docs/architecture.md` need no edit — neither describes the survey at this altitude (checked: zero mentions of survey/declaration/integration). **fidelity ([[verify-intent]]) — pass.** All seven acceptance criteria built and traceable to specific prose; no requirement only partly built. Scope beyond the criteria is limited to two supporting edits that the criteria's mechanism requires (`templates/config.yml`'s absent-means-undeclared comment, `init.md` step 5 reporting an unresolved field) plus the `new-project` arm, which is `findings: DRILL-053-6` on this task and named in its Context — recorded rather than waved through. **correctness ([[code-review]]) — pass with two spawned findings and one fixed inline.** Fixed inline: the probe's report shape was undefined (now `present` with the gap named, not a new survey state). Spawned as **TASK-092**: `init`'s unreachable unattended branch, and declined-vs-never-asked being the same absence. **[[security-review]] — not applicable**: the diff is instructional prose across five skill files, one YAML comment and two markdown records; no auth, data access, input handling, crypto, secrets or dependency surface. 5c skipped entirely — this repo declares `integration: single-branch`, which is step 8's documented skip condition. 5d swept `## Out of scope`: all three pre-existing bullets are boundaries (naming TASK-028, TASK-023, and a deliberate limit); the two new work items got TASK-092 rather than prose.
