---
id: TASK-046
parent: STORY-005
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `verify-intent` — the fidelity axis, grounded in the task's acceptance criteria

## Context

STORY-005's core. The merge gate today answers two questions — *does this follow our documented
conventions* ([[verify-conventions]]) and *is this correct* ([[code-review]]) — and neither asks **did
this build what was asked**. Clean, conventional, correct code implementing the wrong thing passes both.

This task ships the skill with **one** source of truth: the closing task's `## Acceptance criteria`.
That is a complete, useful pass on its own — every task has acceptance criteria, and they are the most
specific statement of intent the repo holds. TASK-047 widens the sources to feature decisions and
`docs/specs/`; this task must be worth running without it.

Three finding classes, per the story:

- **Missing or partial** — a requirement asked for that the diff does not implement, or implements halfway.
- **Scope creep** — behaviour in the diff nobody asked for.
- **Wrong** — a requirement that looks implemented but does not do what was asked.

**Every finding quotes the line it came from.** That is what makes the axis auditable rather than an
opinion: a reader can check the quote against the diff without re-deriving the judgement.

**Named `verify-intent`, not `verify-spec`** — `/specs verify` already means staleness in this skill
set, and two "verify-spec"s would collide on the same repo. "Intent" also covers all three classes
where "scope" covers only two.

**Lands in `skills/`**, never `skills-pi/`, which is frozen — and TASK-037's shadow check now enforces
the consequence of getting that wrong.

## Acceptance criteria

- [x] `skills/verify-intent/` exists with frontmatter whose `description` carries the trigger phrases,
      including the Slovak ones this team uses
- [x] The three finding classes are defined with the branch conditions an agent decides on, as a table
      or short list — not prose
- [x] Every reported finding quotes the acceptance-criteria line it came from, and cites `file:line`
      in the diff
- [x] Runs standalone against the working tree or a named diff, with no task id required — half the
      value is asking "does this match what was asked?" mid-work, before any gate
- [x] Given a task id, it reads that task's `## Acceptance criteria` and reports against them
- [x] States what it does **not** do: it is not correctness ([[code-review]]) and not adherence
      ([[verify-conventions]]), matching how those two disclaim each other
- [x] Resolvable wikilinks and present frontmatter, so the lint has an invariant to check
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Feature decisions and `docs/specs/` as sources** — TASK-047.
- **Wiring into `tasks/close` or `/feature review`** — TASK-049. This task's skill is standalone-only.
- **The smell baseline** — TASK-048; that is the other axis and belongs to `verify-conventions`.
- Auto-fixing findings. Same posture as `verify-conventions`: advisory, the developer applies them.

## Human test plan

- [x] Run it on a real diff from this repo where the task's acceptance criteria were fully met, and
      confirm it reports clean rather than manufacturing findings — run against **this task's own diff**.
      The first pass did **not** report clean: it found criterion 3 partly implemented. Fixed, re-run
      clean. A pass that found a real gap is stronger evidence than a clean first run would have been
- [x] Run it on a diff with a deliberately unimplemented criterion and confirm the **missing** class
      fires and quotes the criterion verbatim — exercised on a **genuine** partial rather than a
      constructed one (criterion 3 above). It fired, quoted verbatim, and classified partial-implementation
      as Missing per the table. Recorded as accidental rather than deliberate: nobody set up the case
- [x] Run it on a diff carrying an unrelated extra change and confirm **scope creep** fires naming that
      change, and does not also report it as missing — run against commit `5214951` (TASK-037) using
      TASK-037's criteria. Two real creep instances fired: the `AGENTS.md`/`architecture.md` check-4
      enumerations, and a `fix-next` rule belonging to TASK-044's surface. Neither was also reported as
      missing. All six of that task's criteria were already ticked, so the ticked-box rule was exercised too
- [x] Run it standalone with no task id and confirm it still produces something useful — see below

## Implementation plan

1. **Read the sibling before writing.** [[verify-conventions]] is the other advisory axis and already
   solved the shape problems this skill has: how to disclaim the neighbouring skill, how to grade
   findings, how to say what it read. Match its section order and its severity vocabulary so a reader
   who knows one knows the other. Do not invent a second reporting style at the same gate.
2. **Router `SKILL.md` only, no `verbs/`.** This skill has one action. A verb tree would be ceremony —
   the convention is that a verb owns its rules *when there are verbs*, not that every skill has them.
3. **Frontmatter** — `name: verify-intent` matching the folder, `description` carrying the English and
   Slovak trigger phrases.
4. **The three classes as a table**, each with the branch condition an agent decides on and what the
   finding must quote. Tables beat paragraphs for anything an agent branches on.
5. **Source resolution, stated narrowly**: with a task id, read that task's `## Acceptance criteria`;
   without one, ask what the intent is or take it from the invocation. Say plainly that this release
   reads *only* the task — TASK-047 widens it — so a reader never mistakes a one-source pass for a
   three-source one. This is the same "say what you read" rule TASK-013 is filing against
   `verify-conventions`; get it right here at birth rather than retrofitting it.
6. **The ticked-box trap.** A closing task's criteria are often already ticked, and a skill that reads
   the ticks instead of the diff would confirm whatever the author claimed. Judge each criterion
   against the **diff**, and treat a ticked box contradicted by the diff as a finding in its own right.
   This is the single most likely way this skill silently becomes useless.
7. **Output format** mirroring `verify-conventions`' three severities, with each finding carrying the
   quoted criterion and a `file:line`.
8. **Run the installers.** A new skill folder gets no junction until `install.ps1` and `pi-install.ps1`
   are re-run — the defect TASK-011 was filed for — so neither runtime can resolve `verify-intent`
   until then, and check 4 will report it missing. This is a step, not an afterthought.
9. **Gate**: `skills-lint.sh`, then `/verify-conventions` and `/code-review`, then the drill.

## Outcome

**What was built.** `skills/verify-intent/` — a router-only skill (one action, so no `verbs/` tree)
carrying the fidelity axis: three finding classes, each quoting the criterion it came from and citing a
`file:line`. It reads one intent source, the closing task's `## Acceptance criteria`, and says so at the
top of every report so a one-source pass can never be mistaken for the three-source one TASK-047 builds.

**The design call that matters: the ticked-box trap.** A closing task's criteria are usually already
ticked, by the person who wrote the change, as a claim. A skill that reads the ticks confirms whatever
the author believed and is worth nothing. So the skill judges every criterion against the **diff** and
treats a ticked-but-unevidenced criterion as a *wrong* finding — the record is untrue as well as the work
incomplete. This is the single most likely way the skill would have silently become useless, which is why
it is a named section rather than a line in the steps.

**The drill found a real gap in this skill, which is the result worth recording.** Run against its own
diff, the first pass did **not** report clean: criterion 3 required every finding to cite `file:line`,
and the Missing row asked only for "what a complete implementation would additionally touch". The tension
was genuine — a missing thing has no location of its own — and the resolution was to cite where the
implementation *should* have gone, which is both satisfiable and more useful: "nothing implements this"
sends a reader hunting, "nothing at `close.md:96` implements this" does not. Criterion **not** rewritten
to fit the result; the skill changed.

**Scope creep was drilled on real history, not a fixture.** Run against commit `5214951` using TASK-037's
criteria, it fired on two genuine instances — the `AGENTS.md`/`architecture.md` check-4 enumerations, and
a `fix-next` rule that belonged to TASK-044's surface — and reported neither as missing. Both came from
`/code-review` findings folded into that commit instead of spawned. The skill would have said "this is two
tasks" at the time.

**Judgement call: router only, no `verbs/`.** The convention is that a verb owns its rules *when there are
verbs*, not that every skill has them. One action, one file.

**Honest limit on this drill.** I authored the skill and ran it, so the pass is not independent. What
partly offsets that is that it found a defect in its own implementation and a scope-creep instance in
already-committed work — neither is what a rubber-stamp produces. An independent run on someone else's
diff is still owed.

**Installers re-run**, per plan step 8: `verify-intent` is junctioned into both roots. Check 4 reported it
missing from both the moment the folder appeared, which is TASK-016's check working exactly as intended.

## Progress log

- 2026-08-20 — `/verify-conventions`: § Naming's verb-noun list gained `verify-intent`. `README.md`'s
  merge-gate documentation still describes two axes; **deliberately not updated here**, because this
  task ships the skill standalone and TASK-049 does the wiring — a README describing a three-axis gate
  today would document fiction. Two criteria added to TASK-049 so it is owned, not remembered.
- 2026-08-20 — `/code-review`: 5 findings, all confirmed. Three fixed here, two filed.
  **Fixed — the tick was allowed to select the finding's class.** The ticked-box section said a ticked
  criterion with no evidence was *Wrong*; the Missing row said no-change-in-diff was *Missing*. Same
  condition, two classes — and since criteria at a close are *usually* already ticked, the ambiguous
  case was the common one. Resolved by making the tick **orthogonal**: the diff selects the class, and a
  false tick is appended as a second, separate record defect. Two runs over one diff now agree.
  **Fixed — EPIC-001's `§ State as of`** still said the epic had no open tasks and told a picker to
  expand a story, three commits after STORY-005 was decomposed into four. Hand-owned by rule, so nothing
  regenerates it; the decomposition commit should have carried it.
  **Fixed — `audit.md` restated the Collection pass's frontmatter list** directly under an instruction
  not to re-enumerate it. The copy had already lost `kind` and `assignee`; `theme` was added without it.
  Converted to a pointer.
  **Filed as TASK-050** — `--unattended` is defined as "no user is present to answer anything" but
  scoped to step 5d, while step 5c still issues a mandatory merge question on PR-per-task projects,
  which is the documented default and exactly where `fix-next` cuts a branch. An unattended drain on a
  default-configured consumer blocks. This repo never sees it because it declares `single-branch` — the
  one configuration that hides the defect is the one it shipped on. Grouped with the second half of the
  same root cause: the unattended 5d branch still permits *decided not to do*, which lets an unwatched
  run rewrite a finding away entirely.
