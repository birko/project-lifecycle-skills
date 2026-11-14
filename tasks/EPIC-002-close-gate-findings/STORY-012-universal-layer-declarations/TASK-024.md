---
id: TASK-024
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
picked-by: fix-next
assignee: agent
created: 2026-08-18
depends-on: []
blocks: [TASK-059]
findings: [SH-89]
pr: null
github-issue: null
jira-key: null
---

# The other owner verbs still cannot say whether an artifact is current

## Context

Spawned from TASK-023's close gate. `AGENTS.md § Conventions` now carries the rule that produced
that task:

> **An owner verb reconciles; it does not assume.** … reports **already current** distinctly from
> **brought up to date** … Applies to every row of `LAYER.md` with an **Owner**, not just the one
> that exposed it.

Only `/tasks init` was taught it. The other owners named in `LAYER.md`'s Owner column still answer a
present artifact with a single undifferentiated "nothing to do":

- **`/specs init`** — re-discovers the area map and proposes a delta, which is most of the way there; what it does not do is report *already current* distinctly from *declined to look*.
- **`populate-tests` `adopt`** — the test-harness row says a working runner is already adopted; nothing checks whether the harness matches the shape that mode now writes.
- **`roll-changelog`** — the changelog row is present-or-absent only; a `CHANGELOG.md` that predates the Keep-a-Changelog shape reads as fine.
- **`[[feature]]`'s index** — owned by `/feature status`, and its row is a prohibition rather than a delegation, so it may not belong in scope at all; decide that explicitly rather than by omission.

**The convention's own wording is now known to overreach** (added by `/code-review` at TASK-020's close,
2026-08-19). `AGENTS.md:120` ends the rule with *"Applies to every row of `LAYER.md` with an **Owner**,
not just the one that exposed it"* — the blanket reading that `LAYER.md` § *Delegation follows the row*
explicitly rejects: *"There is no blanket 'every owner has an init', and reading one into this rule would
send a present brief to the greenfield scaffolder."* Rows owned by [[new-project]] (`docs/BRIEF.md` —
never reconstruct) and [[feature]] (the index — a prohibition) have no reconcile-and-report obligation to
give. So this task also owns **scoping that sentence** to rows whose *Already present?* cell names a verb;
the bullet above stops being a judgement call once it does.

The consequence is asymmetric and quiet: [[adopt-project]] now maps an owner's answer onto a survey
state, and a verb that cannot distinguish those two cases leaves its row `unknown` — honest, but it
means an adoption pass over a fully-adopted repo reports several rows as *"present, and `<verb>`
could not tell me whether it is current"*. That is the correct output for the code as it stands, and
it is noise that will train people to skim the report.

**Not one task per verb, deliberately.** They share one contract and the fix is the same shape in
each; splitting buries what makes them cheap together. Whether each verb needs *reconciliation* or
only the *three-outcome report* differs though, and that judgement per verb is the work.

**Cross-reference from TASK-063, closed 2026-09-01 — these are two tasks, and 063 did not narrow this one.**

TASK-063 asked what a survey does with an agent guide that is present, complete by section, and an older
vintage inside. It **first tried to generalise what counts as an owner** — allowing `present, outdated` to
diff against a template's named rule list rather than a verb's answer — and that attempt was **measured and
rejected**: a membership test for the seed's phrases is a check for the shape `new-project` would have made,
it flags a 239 KB Slovak rulebook as missing four English rules, and it flags this repo's own `AGENTS.md`.
063 closed instead on a **stated limitation**: a guide's rule vintage is content, the survey does not judge
it, and the skill's description no longer promises to.

**What that means here, and it is the opposite of a narrowing:** the bar for `present, outdated` is
**unchanged** — an owner that can report a delta over its own named fields. This task's rows (`/tasks init`,
`/specs init`, …) still qualify in principle, because a config's field set genuinely is enumerable in a way a
hand-written guide's prose is not. **The distinction 063 paid for is the useful part**: an owner may answer
where it wrote the shape itself, and must not where a human wrote the content. Every row here is the first
kind, which is why the limitation 063 accepted does not reach them.

**Third independent corroboration, 2026-09-01.** A cold survey drill over `WorkoutTracker` and `Symbio`
reached this unprompted: *"a bare table cell reading `tasks/: present` looks like a clean bill of health…
the survey format has no way to distinguish 'present and I checked its shape' from 'present and I couldn't
check its shape' other than the reader also knowing the rule."* Both repos' `.config.yml` happen to carry
`mode:` **and** `integration:`, so there was no live gap to find — which is the point: **the format cannot
rule one out**, and a reader who has not read `SKILL.md`'s caveat reads `present` as *done*. That is three
separate drills now landing on this cell.

**Linked 2026-10-06 (EPIC-007 fifth pass, SH-89):** the test-authoring harvest found the same gap in `populate-tests`. `skills/populate-tests/REFERENCE.md:363-364` makes `adopt` do nothing when a harness exists, though `:375-376` say the harness MUST honor its invariants, so an existing non-conforming harness is neither reconciled nor reported.

## Decision (2026-11-14, the user)

Accepted as proposed:
- **The convention** (`AGENTS.md` § *An owner verb reconciles; it does not assume*) applies to rows whose *Already
  present?* cell hands the artifact to a verb, not to every row with an Owner.
- **`/specs init`** reports *already current* when re-discovery proposes no change and *brought up to date* when a delta
  is accepted.
- **`populate-tests` `adopt`** reports an existing harness *already adopted*, notes any invariant it does not meet as a
  finding, and never rewrites it.
- **`roll-changelog`** is not asked: its row is *Present → leave*, and its file says why it has no currency question.
- **`/feature status`** always reports the index *regenerated*: a generated file is rebuilt whole, so currency does not
  apply. Its row is a delegation.

## Acceptance criteria

- [x] Each owner verb reached from `LAYER.md`'s Owner column either reports the three outcomes (**created** / **already current** / **brought up to date**) or records why the distinction does not apply to it — decided per verb, in that verb's file
- [x] Where a verb owns a *shape* that has grown (a template, a required section, a file format), it reconciles an older instance in place: add what is missing, never re-decide what is there
- [x] `/feature status`'s row is settled explicitly — delegation or prohibition — since `LAYER.md` § *Delegation follows the row* keys on that distinction
- [x] `adopt-project` needs no change: it already maps an owner's answer onto a state. Confirm that holds for each verb rather than assuming it, and if a verb's vocabulary does not fit the mapping, that is a finding worth reporting
- [x] An adoption pass over a fully-adopted repo reports **no** `unknown` rows caused by a verb's silence
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- `/tasks init` — done in TASK-023, and it is the reference implementation for the rest.
- Reconciling task/epic/story **frontmatter** against its templates; still its own decision, still unfiled.
- Changing what any of these verbs generates; this is about what they can *say* about an existing instance.

## Human test plan

- [x] Re-drill `adopt-project` on a fully-adopted repo (WorkoutTracker is the candidate — every row present) and confirm no row reports `unknown` because a verb stayed silent
  - **Passed 2026-11-14**, on a fully adopted fixture rather than WorkoutTracker: this task names WorkoutTracker as
    evidence, and a repo a change is justified by cannot be its drill. Cold runners (`claude -p
    --disable-slash-commands`, cwd holding only `skill/`, the d065b brief and the repo; no skills listed).
    `%LOCALAPPDATA%/Temp/d024` re-adopted d378's output: no row `unknown` from a verb's silence (the one `unknown`,
    `LICENSE`, is evidence running out); `/specs init` *brought up to date*, `/tasks init` *already current*, the
    features index *regenerated*.
- [x] For each verb changed, run it twice on a current artifact: *already current*, then no write
  - **Passed 2026-11-14** for `/specs init`, `%LOCALAPPDATA%/Temp/d024b` over d024's committed output: *already current —
    tree size 14 → 14*, the map byte-identical; the repo's diff was the two dashboard timestamps. `populate-tests`
    `adopt` was not reached (see the Outcome).
- [x] For each verb that gained reconciliation, run it on a deliberately old instance and confirm the delta is added and reported
  - **Passed 2026-11-14, as d024's first run:** `/specs init` met a map written before this run's tree, reported
    *brought up to date* and named the key it changed. No other verb gained reconciliation: `populate-tests` reports
    and never rewrites, by decision.
- [x] Confirm a verb that legitimately has no currency question says so in its own file rather than being silently skipped
  - **Passed 2026-11-14, by reading:** `roll-changelog` § *File shape* and `LAYER.md`'s `CHANGELOG.md` row say why
    it has none; the features row says its outcome is always *regenerated*.

## Implementation plan

Inline, from the decision above: one edit per owner, in its own file, and the convention scoped.

## Outcome

**Per owner, in its own file (the decision above):**
- **`AGENTS.md`:** the convention applies to rows whose *Already present?* cell hands the artifact to a verb. A row that
  says *leave it* has no verb to ask, and a generated file reports *regenerated*.
- **`/specs init`** (`verbs/init.md` step 2): a re-discovery reports *created*, *already current*, *brought up to date*
  or *declined*. A moved `tracked-files-at-scan` alone is *already current*, with the refresh named: that key is the
  tree's size, so any added file moves it. d024 first reported 13 → 14 as an update, which is why.
- **`populate-tests` `adopt`** (`REFERENCE.md` § Adopt): an existing harness is checked against the invariants by
  reading, reported *already current* or *left as it is* with each visible miss named, and never rewritten.
- **`roll-changelog`** (§ *File shape*) and `LAYER.md`'s `CHANGELOG.md` row: a present changelog is the repo's history;
  no verb is asked.
- **`/feature status`**: `LAYER.md`'s row is a delegation whose outcome is always *regenerated*.
- **`adopt-project`:** unchanged, as the criteria expected. Its step 3 mapping already reads each new answer: *already
  current* → `present`, *brought up to date* → `amended`, *declined* or *left as it is* → `present, outdated`, and
  step 3c's *regenerated*.

**A limit, recorded rather than changed:** an adoption never reaches `populate-tests` `adopt` once a runner exists,
because the test-harness row ends there ("A repo with a working runner is already adopted — say so and move on"). The
new invariant check runs only when `/populate-tests adopt` is called directly. Sending every adoption through it is a
change to the row's terminating condition, which this decision did not cover.

**Two-runner readings from d024 and d024b, not filed yet:**
- a re-run that finds nothing "writes nothing at all", while `/tasks init` and `/feature status` rewrite their files'
  timestamps every run;
- the CI row's test-step rule names a missing harness or one wired this run, not a harness present with no tests;
- whether the test-harness row's terminating sentence counts as its verb having answered, for *complete*.

**Close gate (inline; five skill files, AGENTS.md and four specs):**
- **Standards:** each verb's rule in its own file; the convention scoped, not copied.
- **Intent:** all criteria met, with the limit above.
- **Correctness:** d024 and d024b.
- **Layer parity:** `LAYER.md` changed only in two row cells both front doors read.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** specs-from-code (the four outcomes), test-authoring (the harness check), changelog-maintenance (a present
  file is left), and project-baseline restamped.

**Unblocks TASK-059** (re-adopting the older consumer repos).

## Progress log

- step 2 — picked after the decision above; it blocks TASK-059; STORY-012 already in-progress
- step 5 — one edit per owner; the convention scoped
- step 6 — behavioural: d024 (no silence-unknown; specs init's size rule corrected after it), d024b (already current, no write)
- step 7 — respecced specs-from-code, test-authoring, changelog-maintenance; project-baseline restamped
- step 8 — closed inline; commit in git log
