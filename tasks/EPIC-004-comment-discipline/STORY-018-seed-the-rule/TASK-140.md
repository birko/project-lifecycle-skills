---
id: TASK-140
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: []
blocks: [TASK-141, TASK-142, TASK-145, TASK-146]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Add the comment-discipline rule to the seeded project rulebook

## Context

Implements FEATURE-002 **D1, D2, D3, D4**, **D12**, **D13**.

> **Reopened and reconciled 2026-09-19.** TASK-147 moved the rule out of `CLAUDE.seed.md` into
> `skills/new-project/templates/CONVENTIONS-universal.md`, which is spliced into the seeded guide at
> `{{UNIVERSAL_CONVENTIONS}}`. The rule reaches consumers exactly as agreed — now byte-for-byte rather
> than paraphrased — so nothing here was undone; only the file holding it changed. Criteria and plan
> below are repointed. The drill record is left as written: it was accurate on the day it ran, and
> editing it would falsify the evidence rather than update it.

`skills/new-project/templates/CLAUDE.seed.md` was the
rulebook every scaffolded project receives; its § Conventions currently covers framework/stack,
UI/UX, code structure, naming and testing, and says nothing about comments. This task adds the
rule there.

The rule is **not a length limit** — that was the requester's opening phrasing (D1a) and was
corrected mid-grill: *"sometimes a comment can be longer but only if it has some necessary info and
not unnecessary things."* So it is necessity per line, and the wording must not smuggle a cap back
in through the side door.

Two existing skills already say fragments of this and must not end up contradicted:
`skills/tasks/SKILL.md` (a comment reading *"should be fixed properly one day"* is work that
silently disappears — file a task) and `skills/fix-next/SKILL.md` (a test comment **must** name the
finding id and state the mechanism). Both are consistent with the new rule; check the wording keeps
them that way rather than assuming it.

Which § Conventions subsection it belongs under is a judgement call to make while reading the file
— *Code structure & patterns* is the obvious candidate, a subsection of its own is defensible if
the rule reads badly wedged in. Say which you chose and why in the close notes.

## Acceptance criteria

- [x] The seeded rulebook states the rule as **necessity per line, never a line count** — now in `templates/CONVENTIONS-universal.md`, spliced into `## Conventions` (repointed 2026-09-19; it named `CLAUDE.seed.md`, which TASK-147 emptied of this block).
- [x] The five-destination test is written out: code / version history / the ticket / a decision record / **nowhere**, with only *nowhere* surviving at any length.
- [x] The four banned instances are named concretely: changelog, QA log, rationale essay above a declaration, a 10-line block on a single property/const/enum/field.
- [x] The doc-comment clause (D12) is present: a docstring / XML doc / JSDoc survives the "restates the signature" destination because it is a published output, **and its content is still judged line by line** — no changelog, no QA note, no padding, each line earning its place by what it adds beyond the signature.
- [x] **No numeral in the section can be read as a threshold.** Three appear and each is anti-cap by construction: *"ten lines"* (a banned instance, shown passing in a different position two clauses later), *"thirty-line"* (the compliant-long exemplar the plan mandated), and *"one line"* (what a pointer is, not a limit). No "1–3 lines", no "keep it short", nothing a reader can lift out and enforce. Evidence is the cold drill, not a re-read (D1, grill outcome).
- [x] The section is delimited by marker lines so TASK-146's lint check can anchor on it (D13), and the markers do not render as visible clutter in a consumer's rulebook.
- [x] The prose obeys this repo's own output rules — imperative, addressed to the agent, rationale stated inline and briefly.
- [x] No unrendered template token is introduced.
- [x] `skills/tasks/SKILL.md` and `skills/fix-next/SKILL.md` were read and confirmed non-contradictory; if either needed a word changed, that change is in this diff.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- **Backfilling the rule into already-adopted repos** — FEATURE-002 **D5**, approved as a decision *not* to do this. [[adopt-project]] reconciles which artifacts exist and what shape they are in; it has never judged the prose inside a hand-written document, and the first time it does becomes the precedent every later prose rule cites. The `review-comments` command (STORY-019) is what reaches those repos.
- **Deferred to TASK-145** — patching `skills/new-project/SKILL.md:89`, whose "leave these sub-blocks as-is" sentence names two sub-blocks and goes one short the moment this task adds a third. Spawned during planning rather than folded in: it is a defect in the scaffolder's instructions, not in the rule's wording, and a reviewer would judge it separately.
- This repo's own `AGENTS.md` — TASK-141.
- **Deferred to TASK-146** — the lint check that asserts the seed's block and `AGENTS.md`'s block match (D13). This task only writes the markers; the check needs both copies to exist, so it lands after TASK-141.
- **Documenting the marker convention** (raised by `/verify-conventions` at this close) — assigned to TASK-146, which owns the contract's reading side; it now carries an acceptance criterion for it. Not spawned as a new task: a one-line rule with an existing owner is a boundary, and fragmenting it from the check that reads it would bury the connection.
- Building or wiring the command — STORY-019.

## Human test plan

A cold drill. The reader must not have been told the rule exists, or the test degrades into a
confirmation — see [[populate-tests]] § *The cold drill* and § *Acquiring a cold runner*. Note that
this repo's skills are installed at user level, so **every agent on this machine already holds
them**; the runner has to be obtained with `--disable-slash-commands` in a guide-free working
directory, and the drill record must name the command, the working directory, and the result of the
coldness check.

- [x] Scaffold a throwaway project with `/new-project`. Expected: its `CLAUDE.md` § Conventions contains the comment rule, with the five-destination test and the four named instances.
- [x] Give the cold runner a file containing three comments — a 10-line changelog above a `const`, a 2-line comment restating the line below it, and a 30-line block explaining a genuinely non-obvious algorithm — and the scaffolded `CLAUDE.md`. Ask which comments violate the project's conventions. Expected: it flags the first two and **keeps the third**, citing length for neither.
- [x] Add a fourth fixture for D12: a docstring whose summary restates the method name, carrying two extra lines of changelog inside it. Expected: the runner **keeps the docstring** and flags the changelog lines within it. Expected failure in either direction — deleting the whole docstring (the carve-out did not land), or passing it untouched (the carve-out was read as a blanket exemption, which is not what was asked for).
- [x] Expected failure mode to watch for: the runner flags the 30-line block *because it is long*. That means the wording smuggled a cap back in and the task is not done.

### Drill record — 2026-09-18, PASS

**Runner acquisition.** A separate `claude -p` process (CLI 2.1.276), launched with
`--disable-slash-commands`, working directory
`…/scratchpad/drill-140` — outside this repo, no `AGENTS.md`, no `tasks/`, no `docs/`. Fixture:
a `CLAUDE.md` for an invented project ("Warehouse Sync") carrying five § Conventions subsections
including the new § Comments block verbatim, plus one `src/reconcile.ts` holding four comment
blocks. Brief, in full: *"Review the comments in src/reconcile.ts against this project's conventions
in CLAUDE.md. For each comment block in the file, say whether it should stay or go, and why."*

**Coldness check — partial, and stated as such.** The brief withheld every expected answer, and the
runner's context held no part of this repo. What cannot be claimed is total context coldness: these
skills are installed at **user level**, so the machine holds them and the runner could in principle
have read `CLAUDE.seed.md`. No contamination signal appeared — it never referenced the skills repo,
quoted only the fixture rulebook, and reached verdicts by applying the test rather than by recognising
it. Classified **cold on the brief, uncontaminated on the evidence, not provably cold in context.**

**Result — 4/4.**

| Fixture | Required | Runner |
|---|---|---|
| ten-line changelog + QA log above a `const` | flag | GO — "every line is one of the two named violations" |
| two-line comment restating the line below | flag | GO — "already carried by the name, the return type, and the line below" |
| ~20-line algorithm block | **keep, and not on length grounds** | "STAYS, in full. This is twenty lines and that is not a finding." |
| JSDoc restating the signature, changelog inside | keep block, cut the changelog lines | "MOSTLY STAYS, two lines go" — cut exactly those two |

**The wording held where it was designed to break.** Length was named as a non-finding unprompted.

**Three unprompted behaviours, none designed for**, each evidence the rule generalizes rather than
pattern-matches: it applied the relocate-before-delete rule (D9) to two lines whose content lived
nowhere; it identified a rationale-essay clause *inside* the block it kept and reasoned that it belongs
in an ADR but is the only copy until one exists; and it found a real defect in the fixture code
(`.filter(Boolean)` after a `.map` that cannot yield falsy) and routed it as its own task rather than a
comment finding.

**One gap found, and fixed in this task.** For a structurally required tag that adds nothing
(`@param tolerance the tolerance`), the clause pulled two ways — cuttable by "cut the ones that add
nothing", uncuttable by "a build may require it". The runner resolved it by judgement; the clause now
states the resolution (fill it, do not delete it). Logged on FEATURE-002 D12's History.

## Implementation plan

> ✅ **Resolved 2026-09-18 — recorded as FEATURE-002 D12, and an acceptance criterion added above.**
> The stakeholder's answer narrows the carve-out: the doc comment survives, **its content still gets
> checked** for padding and for information that belongs elsewhere. It is exempt from one destination,
> never from the test. The optional clause in step 2 is therefore **required**, in that narrower form.
>
> The question as raised: the criteria didn't say whether the
> rule covers **generated-documentation comments** (docstrings, XML `///` docs, JSDoc). The
> five-destination test read literally deletes most of them — `/// <summary>Gets the user id.</summary>`
> is content that "already lives in the code itself" — yet in many stacks they are a published artifact
> and sometimes compiler-enforced. The cold drill cannot surface this: its three fixtures are all plain
> comments, so a consumer agent would be the first to hit it. Either add one clause to the rule, or
> state explicitly that it is STORY-019's problem. An optional clause is drafted in step 2 below.

### 0. What is actually being built

One prose block in the seeded rulebook — written into `CLAUDE.seed.md` here, relocated to
`templates/CONVENTIONS-universal.md` by TASK-147. No code, no build. The whole risk is
in the wording, and the wording has four specific traps (§ 4). *(The plan originally also covered a
clause in `skills/new-project/SKILL.md`; that is now TASK-145.)*

### 1. Placement decision (the judgement call the task asks for)

**A new `### Comments` subsection of § Conventions, inserted after the § Testing block and before
`### Keeping conventions current`.** Not a bullet under *Code structure & patterns*. Four grounds,
descending:

1. **Code structure & patterns is a render target; this rule is not.** `skills/new-project/SKILL.md:86`
   tells the scaffolding agent to *"seed the stack's idiomatic defaults"* there, and that subsection holds
   exactly one line: `- {{CODE_STRUCTURE_RULES}}`. Static universal prose beside a token the renderer is
   told to replace is prose the renderer will paraphrase, reorder or drop — silently, per project, and
   invisible to the lint. The seed's two existing universal blocks both live at the end, after the
   per-project ones; this rule is universal the same way.
2. **Size.** The five-destination test wants a table (this repo's own rule: tables beat paragraphs for
   anything an agent must branch on) plus four named instances — about 25 lines. As one bullet under a
   one-bullet subsection it reads wedged, which the task names as the condition for splitting it out.
3. **Nothing downstream hard-codes the `###` list.** `skills/adopt-project/LAYER.md:354` scopes its
   inventory to the seed's `##` headings only; `skills/verify-conventions/SKILL.md:42` reads *"§ Conventions
   and its subsections, when present"* off the file, and its own sample report already names two
   subsections its illustrative bullet list omits. Do **not** add a row to `verify-conventions` — D6
   forbids a second copy of the rule there.
4. **It gives STORY-019 and TASK-141 a stable anchor** (`§ Conventions › Comments`) instead of "the third
   bullet under Code structure".

### 2. Proposed section text (drop-in)

```
### Comments

Write the comment the code cannot carry, and nothing else. Judge each line by **what it carries, not
how many there are**: a long block where every line earns its place is correct, and a two-line comment
restating the line below it is not.

**The test — delete the line, then ask where its content already lives:**

| It already lives… | Then |
|---|---|
| in the code itself — the name, the type, the signature, the line below | delete it; if the comment was compensating for a bad name, fix the name |
| in version history — the commit message, `git blame` | delete it; that is what the history is for |
| in the ticket — `tasks/` | delete it; if the work is not filed yet, file it (`/tasks spawn`) and then delete it |
| in a decision record — `docs/adr/`, the feature's `decisions.md` | delete it, or leave one line pointing at the record |
| **nowhere** | **keep it, at whatever length it takes** |

Only *nowhere* survives, and it survives at **any** length. *Nowhere* means the content has no home
but this comment — not merely that nobody has written it down yet. Content that belongs in one of the
first four rows goes there first, then the comment goes. Never delete the only copy of something:
relocate it, then leave the pointer.

**A pointer is not a copy.** One line naming where the rest lives is what makes the destination
reachable, and it always survives — a test comment naming the finding it pins and the mechanism it
proves, a line citing the record that explains a choice. What fails the test is reproducing the
content here.

**These four are always violations, and none of them is about length:**

- **A changelog** — "2025-03-04 added X; 2025-05-11 renamed Y". Version history already has it.
- **A QA log** — "tested 3.4.2025, works". That belongs in the ticket, or in a test that asserts it.
- **A rationale essay above a declaration** — the paragraph arguing why this approach beat the
  alternatives. That is a decision record.
- **Ten lines of prose above one property, const, enum member or field.** The length is the symptom;
  the violation is that nine of them restate the name. The same ten lines above an algorithm whose
  correctness is not visible from the code are correct.

**Never report a comment for being long.** A thirty-line block explaining a non-obvious algorithm, a
protocol quirk, or why the obvious implementation is wrong is compliant — every line carries something
the code cannot. Comments that pass this test usually come out short, because most content has
somewhere better to live; that is an outcome of the test, never a limit on it. Length is a reason to
look, never a finding by itself.
```

Optional fifth paragraph, only if the ⚠ above is answered "cover it here":

```
A doc comment (docstring, XML doc, JSDoc) is a published output rather than commentary — keep it, and
hold each of its lines to the same test for what it adds beyond the signature.
```

### 3. Steps

1. **Re-verify the two neighbours on the real diff** — `skills/tasks/SKILL.md:384-385` and
   `skills/fix-next/SKILL.md:226-227`. Neither needs a word changed, but only because of two specific
   sentences in the draft (§ 5). Record that reasoning in the close notes, not a bare "checked".
2. **Insert the block** after § Testing. Keep the seed's heading style, its bold-lead-then-rationale
   bullet rhythm, and its em-dash punctuation.
3. **Patch the renderer instruction** — `skills/new-project/SKILL.md:89` reads *"Leave the
   register-on-introduce + working-rules sub-blocks as-is."* That becomes a one-short restated list the
   moment a third static sub-block exists (this repo's own test: *would this sentence become wrong if the
   file gained a row?* — yes). Rewrite it as *"Leave every subsection that carries no `{{…}}` token
   as-is"*, which cannot go stale. **Not optional polish:** without it the next scaffold run is licensed
   to rewrite the block, defeating D4. → **deferred to TASK-145.**
4. **Do not touch** `skills/adopt-project/INFER.md:45-53`. Adding a Comments row makes the adopter infer
   a prose rule from code — the precedent D5 exists to prevent.
5. **Run the gate:** `bash .github/workflows/skills-lint.sh`.
6. **Cold-read the diff yourself as the drill runner would**, answering one question: *given only this
   text, is a 30-line algorithm comment a violation?* If any sentence could be quoted to say yes, it is
   not done.
7. **Close notes carry:** the placement choice + why, the non-contradiction finding, and the fact that
   the cold drill — not the lint — is the acceptance evidence.

### 4. The wording problem, trap by trap

The drill fails if a cold reader flags the 30-line block *for being long*. Four ways that happens:

- **Numeral anchoring from the fourth banned instance.** AC 3 mandates naming "a 10-line block on a
  single property/const/enum/field". Ship that numeral bare and a reader derives a cap from it — the one
  thing D1a removed. Defused by spelling it out (*"Ten lines of prose above one property…"*, so it reads
  as an instance not a threshold), stating *why* it fails in necessity terms, then showing the same ten
  lines passing in a different position. Do not write "10-line block" as a bare noun phrase.
- **Expressing "1–3 lines is the normal case".** Use the numeral-free form: *"Comments that pass this
  test usually come out short… that is an outcome of the test, never a limit on it."* **Recommendation:
  no numeral at all.** The drill is scored on precisely this and nothing is lost.
- **No compliant-long exemplar.** A cold reader cites examples, not principles. The *thirty-line block*
  sentence is deliberately longer than any number elsewhere in the section and is what the runner is
  expected to quote when keeping the third fixture. Do not cut it for brevity.
- **"Necessary" as the standard.** Every author believes their comment is necessary (D2's rationale).
  The word appears nowhere in the draft; the decidable delete-and-ask procedure carries the whole rule.

### 5. Non-contradiction finding (not a formality)

Both neighbours are consistent — **but only because of two sentences in the draft. The naive version of
the rule contradicts both.**

- **`fix-next`** requires a test comment naming the finding id and the mechanism. Under a bare
  five-destination test that content "already lives in the ticket", so the test would order it deleted.
  The **"A pointer is not a copy"** paragraph prevents it, and names the test-comment case for that
  reason. Drop that paragraph and AC 6 flips to a real contradiction.
- **`tasks`** outlaws a comment reading *"should be fixed properly one day"*. Under a bare test that
  content lives **nowhere**, so the naive read *keeps* it. The **"*Nowhere* means the content has no home
  but this comment — not merely that nobody has written it down yet"** sentence, plus the `/tasks spawn`
  cell in the ticket row, routes it correctly. Drop either and the new rule licenses exactly the comment
  `tasks` outlaws.

Conclusion to record: **no edit to either file.** The reconciliation lives in the new prose, which is
where a rule's carve-outs belong.

### 6. Lint and template traps

- Checks 2 (wikilinks) and 4 (cross-skill flags) **do** scan `templates/`; only check 3 excludes it. So
  **no `[[wikilinks]]` in the seed** — it has zero today, deliberately, because it ships into repos where
  those names may not resolve. Use the bare `/tasks spawn` form the rest of the seed uses, and **no
  `--flag` invocations**.
- **Never name `review-comments` in this diff.** It does not exist until STORY-019; a wikilink would fail
  check 2 outright, and a bare mention ships a consumer rulebook pointing at a command their install does
  not have.
- **No `{{TOKEN}}`** in the new block (AC 5) — it is static by design.
- **No code fences** in the new block: check 2's unbalanced-fence guard is fatal, and a fenced example
  would be stripped from linting while inflating every consumer's auto-loaded context.

### 7. Tradeoffs and residual risks

- **Context cost.** This file is auto-loaded into every task in every scaffolded project. ~30 lines; the
  table earns its place because the branch is real. Resist growing it with worked examples — that is what
  STORY-019's command is for.
- **Three-copy drift — the structural worry.** After TASK-141 the wording exists in the seed *and* in
  this repo's `AGENTS.md`, and STORY-019 may embed a third. The five destinations are a *list that can
  grow*, exactly the shape § *Defer to a shared inventory* warns about — and no pointer is possible,
  since a consumer install cannot see this repo. Mitigation to hand forward: TASK-141 copies the seed
  wording **verbatim** and names the seed as its source, and `review-comments` is built to **read the
  project's own § Conventions** rather than carry its own copy.
- **`AGENTS.md:207-211`** (config templates ship a field commented out, comment left in place) is a
  comment whose content lives nowhere else and therefore survives — no conflict, but flag it for
  TASK-141/STORY-019, where a sweep over this repo could misread a schema-carrying comment as commentary.
- **The gate is the drill, not the lint.** `skills-lint.sh` cannot see a word of this rule's meaning. The
  only evidence AC 1 holds is the cold-runner drill. Plan for it to fail once and the wording to need a
  pass — budget for that rather than treating the edit as the end.
