---
id: TASK-122
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-09
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The slicing doctrine — what "atomic and independently completable" actually means

## Context

`decompose` and `plan` today say a task should be *"atomic and independently completable"* and stop
there. That is a property to check, not a method to follow, so the actual slicing is improvised every
time — and the failure it produces is specific: **tasks that cannot land green on their own.**

The doctrine, from the story:

- **Vertical, not horizontal.** Each slice cuts a narrow but complete path through every layer — not a
  slice of one layer across the whole feature.
- **Demoable or verifiable alone.** A completed slice can be shown or checked without its siblings.
- **Sized to one fresh context window.** Not "small"; a stated, checkable bound.
- **Prefactoring goes first** — make the change easy, then make the easy change.

### The design question this task must settle, not assume

**Where the doctrine lives.** Two verbs consume it — `/tasks plan` and `/feature decompose` — and this
repo's rule is that a vocabulary shared by several skills has **one owning file, and the owner is
wherever it already lives**. Nothing owns slicing today, so this task picks the owner and the others
point at it. Expanding an existing home beats minting a neutral one; a partial copy is worse than
either, because it diverges like a full copy while being silently narrower.

**"One fresh context window" needs an operational reading.** As written it is a metaphor. A slicer needs
to know what to actually check — files touched, layers crossed, whether the task's own Context can be
read without opening anything else. Left as prose it becomes taste, and taste is what the doctrine
exists to replace.

### Merged in 2026-09-26: TASK-123 — Wide refactors — the case no vertical slice can cover, sequenced expand → migrate → contract

_Merged because wide refactors are the doctrine's own named exception; the doctrine is incomplete without it. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-123.md`._

TASK-122's doctrine has one explicit exception, and it is not a rare one: **a mechanical change whose
blast radius fans across the codebase** — rename a shared symbol, retype a column. It breaks thousands
of call sites at once, so **no vertical slice can land green**. A doctrine that does not say this sends
a slicer to produce slices that cannot exist.

#### The sequence, from the story

| Phase | Shape | Task shape |
|---|---|---|
| **expand** | add the new form beside the old so nothing breaks | one task, blocks everything below |
| **migrate** | move call sites in batches **sized by blast radius** | one task per batch, each blocked by the expand; CI green batch to batch, because the old form still exists |
| **contract** | delete the old form last | one task, blocked by **every** batch |

**And the escape hatch, which is the part that is easy to drop:** when even the batches cannot stay
green alone, they share an integration branch and all block a final **integrate-and-verify** task —
green is promised only there, and the sequence says so rather than pretending each batch is safe.

#### Why this is a task-shape rule, not just advice

Every phase above is expressed in `depends-on` / `blocks` edges. That makes it something `/tasks new`
and `/feature decompose` must be able to *emit*, not merely describe — and it collides with a known
limitation: **TASK-001**, *"STORY.md cannot express dependency edges"*. This task must state where the
edges live for a refactor sequence, given that constraint.

The integration-branch case also touches `.config.yml`'s `integration:` declaration — a repo on
`single-branch` has nowhere to put a shared integration branch. That interaction needs an answer, not
an assumption.

**Size signal kept as one task:** 13 criteria trip `audit`'s `splittable` row, but the change is one
owning file plus one-line pointers. The pointers fail lint check 3 if they land before the file, so a
split would fail H3.

## Acceptance criteria

- [x] The four rules are written where a slicer will read them, in one owning file, with the owner chosen
      and the reason recorded
- [x] `/tasks plan` and `/feature decompose` both reach the doctrine — by pointer, never by copy
- [x] **Vertical vs horizontal** is illustrated with a worked pair on this repo's own material: one
      slice that lands green alone and one that cannot, so the distinction is demonstrated rather than
      asserted
- [x] "Sized to one fresh context window" has an operational test a slicer can apply
- [x] Prefactoring is stated as an ordering rule — the prefactor is its own slice, before the change it
      enables, not folded into it
- [x] The doctrine says what to do when a change **cannot** be sliced vertically, and points at
      TASK-123 rather than leaving the case open — met by writing the wide-refactor case into the doctrine
      itself (§ *Before slicing*, § *Wide refactors*); a pointer to the cancelled TASK-123 cannot ship in a skill file
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-123:*

- [x] The three phases are written with their task-shape consequences — which task blocks which, and
      why CI stays green between batches
- [x] **Batch sizing is defined by blast radius**, with a stated way to measure it, not by a count
      pulled from the air
- [x] The integration-branch fallback is included, including that green is promised only at the final
      integrate-and-verify task
- [x] The interaction with `integration: single-branch` is answered — what a repo with no branch-per-task
      does when the batches cannot stay green
- [x] Where the edges are recorded is stated, given that `STORY.md` cannot carry them (TASK-001)
- [x] The exception says how to recognise it **before** slicing, so a slicer does not discover it after
      producing slices that cannot land
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- ~~**Wide refactors** — TASK-123, the explicit exception, which depends on this rule existing.~~ Void since the 2026-09-26 merge: now in scope.
- **`/feature prototype`'s fourth form** — TASK-124, the story's other half.
- Changing what `plan` or `decompose` otherwise do.

*From TASK-123:*

- ~~**The general doctrine** — TASK-122.~~ Void since the merge: this is TASK-122.
- **Fixing STORY.md's inability to carry edges** — TASK-001 owns that; this task works within it.
- Automating the batch split. This is doctrine an agent applies, not a tool.

## Human test plan

- [x] Give a cold runner — per [[populate-tests]] § *Acquiring a cold runner* — a real undecomposed
      story from this repo and the doctrine, and have it slice. Expected: it produces vertical slices and
      says which rule rejected any slice it discarded. Withhold both from its brief.
  - **Run 2026-09-29, passed.** Fixture: STORY-004's `STORY.md` alone, its tasks withheld (the STORY names none). Runner: `cd C:/Source/WebChecker && claude -p --disable-slash-commands < brief1.txt`, with the doctrine and the story pasted in. Coldness: WebChecker has no guide, and the runner reported no skills or slash commands loaded. The brief asked for the discarded candidates "and why", but did not name a rule or the expected shape. Result: it ran the pre-slice test first (no wide refactor, since both forms coexist), then gave six vertical slices with edges on both sides (T1 → T2 → {T3, T4}; T5 → T6 in parallel). It gave ten discarded candidates, each naming the rule that rejected it: "template/table first" by *Vertical, not horizontal*; the whole story by H1 plus the owner signal; the claim marker folded into T2 by the reviewer signal. Three doctrine gaps it raised were fixed in place: H3 is green-but-incoherent in a prose repo; a shape one owner writes and another reads is an edge; where the parent is given.

*From TASK-123:*

- [x] Take a real wide change — a shared rename in this repo's own skills would do — and sequence it by
      the rule without executing it. Expected: the emitted task set has an expand nothing depends on,
      batches that each depend only on the expand, and a contract depending on all of them.
  - **Run 2026-09-29, passed.** Fixture: renaming `## Human test plan` to `## Manual verification`, in a clone of this repo at `%TEMP%/d122` with `tasks/` (except `.config.yml`: `single-branch`), `docs/`, `AGENTS.md`, `CLAUDE.md` and `CHANGELOG.md` removed. `grep` found no mention of TASK-122 or TASK-123 left. Runner: `claude -p --disable-slash-commands --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob < brief2.txt` from the clone. It reported no skills loaded. Result: it measured 45 lines in 20 files across 6 owners, found `templates/TASK.md` as the only writer, and counted three templates rendered into consumer repos. It then gave: T1 expand, where readers accept both headings (depends-on none, blocks all); four owner batches T2–T6, each depending only on T1; T7 contract, which switches the template and depends on T1–T6. Its gaps were fixed in place: a writer that cannot carry both forms means expand on the read side; the alias for out-of-reach copies is permanent; the parent comes first; a gate already red is judged as "no new failures". Its H3 point had already been fixed after drill 1, since this runner had the earlier text.


## Implementation plan

Drafted 2026-09-29 by a `Plan` subagent at `/tasks pick`; facts checked against the tree before writing.

⚠ Acceptance criteria question: the **Out of scope** bullets "Wide refactors — TASK-123" and "The general doctrine — TASK-122" were carried over by the 2026-09-26 merge and now contradict the merged criteria. Treat both as void; the other three still hold.

⚠ Acceptance criteria question: the lint criterion appears twice. One run ticks both.

⚠ Acceptance criteria question: "points at TASK-123" cannot be met literally, since TASK-123 is cancelled and a skill file ships to consumer repos. Met by writing the wide-refactor section inside the doctrine itself; say so at close.

⚠ Acceptance criteria question: 13 criteria trips `audit`'s `splittable` signal (≥6). Kept as one task because the change is one owning file plus one-line pointers, and pointers committed before the file exists fail lint check 3. Recorded here as the doctrine's own required justification.

### Design decisions

1. **Owner: a new `skills/tasks/slicing.md`.** `feature/verbs/decompose.md` already points at "the [[tasks]] granularity rule", which does not exist, so the owner is named and only the target is missing. Not a verb file (five readers: `plan` 5b, `new`, `spawn`, `audit`, `decompose`), and not the 474-line router. Precedent: `tdd/refactoring.md`. New file in an existing folder, so no installer re-run. The numeric size thresholds stay in `audit.md`'s `splittable` row, by pointer.
2. **"One fresh context window" = three hard checks plus signals.** H1: the Context stands alone with other task ids struck out. H2: the criteria and test plan are checkable with no sibling landed. H3: once its `depends-on` are done, the gate cannot be red after this change. Signals (audit's `splittable` row by pointer, more than one owner edited beyond pointer lines, a reviewer judging two things) each need one written justification line when tripped. No invented file-count threshold.
3. **Worked pair from this repo.** Green alone: TASK-051, which shipped the `domain` folder together with turning existing mentions into `[[domain]]` links. Cannot land: the horizontal cut "links first", which fails lint check 2; TASK-074 records `INFER.md` held in plain text for three days. Prefactor order: TASK-140/141 before TASK-146's check 5. Written to stand without the ids, plus a one-line code-repo translation.
4. **Wide refactors.**
   - **Pre-slice test:** does the change alter something others read, and does the old form's grep span more owners than one slice may touch? If both, use expand → migrate → contract. If the old and new forms cannot coexist, use the fallback.
   - **Edges:** on TASK frontmatter, both sides (`blocks` + `depends-on`), all under one parent, since STORY.md has no edge fields. Emitted with `/tasks new task --no-plan`, never `/tasks block --on`, which sets `blocked`. `audit` checks the result.
   - **Blast radius = fan-out, not [[fix-next]]'s severity.** In prose, grep grouped by skill folder, marking which references a lint check resolves and counting copies rendered into consumer repos. In code, compiler references grouped by owner, plus what the compiler cannot see. One batch = one owner group.
   - **Fallback under `pr-per-task`:** batches share an integration branch and close via `close` 5c's defer path (`blocked`, with the reason note naming the integrate-and-verify task, and no back-edge, which would be a cycle). Integrate-and-verify is the only green promise.
   - **Under `single-branch`:** no shared branch exists. Collapse the non-green batches into one task, or widen the expand with an alias or adapter so the forms coexist, and report which was done. Never flip the declaration, since a policy minted for convenience is what *Read the declaration, never infer it* forbids.
5. **Pointers.**
   - `plan.md` 5b and `decompose.md:24` (replacing the dangling pointer): link to the doctrine.
   - `new.md` step 2, `spawn.md` step 1 and the `tasks/SKILL.md` router (~445): one clause each.
   - `tdd/SKILL.md`: unchanged. slicing.md says the two differ: tdd's is test/code order inside one task.
   - `CLAUDE.seed.md:23`: unchanged. It is a correct summary, not a list; it routes into `decompose`; and a seed edit would not reach adopted repos.

### Steps (one change, one commit — pointers before the file would fail check 3)

1. Write `skills/tasks/slicing.md`, at most ~150 lines, tables first. Sections: the four rules (prefactor as its own blocking task), the worked pair, one fresh context window, before slicing (the exception test), wide refactors, blast radius, where the edges live, when batches cannot stay green, not to be confused with, and reporting the rule that rejected each discarded slice.
2. Add the pointer lines in SKILL.md, `plan.md`, `decompose.md`, `new.md` and `spawn.md`.
3. `bash .github/workflows/skills-lint.sh`. Watch check 3 (relative paths) and check 4 (any `/tasks … --flag` in slicing.md).
4. Add a back-pointer line to TASK-001's Context: slicing.md § *Where the edges live* must change when TASK-001 lands.
5. Run the drills, then close (single-branch: no merge step).

### Drill fixtures

- **Disqualified,** because the doctrine names them: STORY-003, STORY-015, STORY-018 and STORY-006. STORY-007 is contaminated on link ordering.
- **Drill 1:** STORY-004's STORY.md alone, with its tasks withheld.
- **Drill 2:** the wide rename of the `## Human test plan` heading (≈15 files, 5 skills, plus rendered copies in consumer task files), sequenced but not executed.
- **Runner:** `claude -p --disable-slash-commands` from a guide-free directory, with slicing.md and the fixture pasted into the brief, since the junctions make the file live in every session. Record the command, the directory and the coldness check.

### Risks

- The integration-branch fallback has no `pick` support; `pick` cuts from the default branch. The doctrine says this step is manual, and a failure in the drill gets spawned, not widened into this task.
- The size signals are soft. They hold only if `plan` 5b asks for the justification line.

## Progress log

- 2026-09-29 — Picked; plan drafted by a `Plan` subagent. The user chose: owner `skills/tasks/slicing.md`; `single-branch` collapses non-green batches or widens the expand, never flipping the declaration; keep as one task.
- 2026-09-29 — `skills/tasks/slicing.md` written (four rules, worked pair, H1–H3 plus signals, pre-slice test, expand → migrate → contract, blast radius, edges, the fallback per `integration:`, report what you rejected). One-line pointers added in `tasks/SKILL.md`, `plan.md` 5b, `new.md` step 2 and `spawn.md` step 1. `decompose.md`'s dangling "granularity rule" pointer replaced, and its too-big edge case given the pre-slice test. Back-pointer added on TASK-001. Registered in `AGENTS.md` § Conventions as the second instance of the one-owning-file rule.
- 2026-09-29 — Both drills passed; seven doctrine gaps they raised fixed in place (records above). Lint OK; lint test suite 63/63.
- 2026-09-29 — Close review. **Standards:** pass after two fixes. The opening had listed the file's readers, a list that grows, so it now says "every verb that creates, splits or sizes a task". The `single-branch` row gave a fixed report line for only one of its two outcomes, and now gives both. The new owner is registered. **Intent:** pass. All 13 criteria met; the TASK-123-pointer criterion was met by an inline section, annotated. **Correctness:** pass. Every cross-verb claim was checked against its verb: `new`'s `--no-plan`/`--from-feature`, `block --on` setting `blocked`, `close` 5c's defer to `blocked`, `audit`'s `broken-links`/`cycles` rows, and `pick` warning on unmet `depends-on`. **Security:** not applicable, no security surface. **Comments:** not applicable, no code comments in the diff.
- 2026-09-29 — Out of scope, work: drill 1 showed STORY-004's TASK-114 ("the shape every other task reads") is the horizontal "template first" cut the doctrine rejects → TASK-195.
