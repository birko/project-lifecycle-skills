---
id: TASK-142
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-140]
blocks: [TASK-143, TASK-144]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Create the `review-comments` skill — the check and its two scopes

## Context

Implements FEATURE-002 **D6, D6a, D7**. A new skill folder under `skills/` (never `skills-pi/`,
which is frozen) that owns the comment-discipline check.

**It owns the check; [[verify-conventions]] does not get a second copy of the rule.** That skill
lints diffs against whatever the project's own guide records, so once TASK-140 lands it already
sees the rule as one line in a rulebook. What it cannot do is sweep code nobody is changing — and
the whole reason this command exists is the ten-line block written two years ago in a file no
current task touches.

The name is settled: **`review-comments`**. `verify-comments` was rejected because the `verify-*`
family here means report-only and a member that writes files empties the name; `prune-comments`
was rejected because it understates the relocation half (TASK-143).

Scopes, both explicitly asked for: **default is the work in hand** (the current diff), `--all` is
the whole repository. Note the consequence the grill flagged for `--all` — a whole-repo sweep can
produce hundreds of findings, and a report nobody can read is where a wrongly-deleted comment slips
through. How findings are batched or paged on `--all` is a real design question for this task, not
a detail; whatever you choose, say why in the close notes.

Adding a new skill folder means **both installers must be re-run** before either runtime can
resolve it — one junction is created per folder at install time.

## Acceptance criteria

- [x] `skills/review-comments/SKILL.md` exists with mandatory frontmatter: `name: review-comments` matching the folder, and a `description` carrying the trigger phrases users actually type, including Slovak.
- [x] The router stays small; detail lives in the file that owns it.
- [x] The check is stated as the five-destination test, pointing at the rule's owning file rather than restating it — the same deference this repo requires of any shared inventory.
- [x] Default scope is the current diff; `--all` widens to the whole repository. The default run is what happens with no flag passed.
- [x] `--all` declares how it batches or pages findings, and why that choice was made.
- [x] Any flag this skill declares, and any flag it passes to another skill's verb, satisfies the lint's flag-contract check.
- [x] Cross-skill references use `[[name]]` and resolve.
- [x] Both installers re-run, and the lint's install-root check reports no drift for the new folder.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The only-copy relocation path — TASK-143. This task may report such a comment; it must not delete one.
- Wiring into `/tasks close` — TASK-144.
- Comment *style* (formatting, doc-comment syntax, language) — out of scope at the epic level.

## Human test plan

A cold drill, acquired under the same rules as TASK-140 (`--disable-slash-commands`, guide-free
working directory; the drill record names the command, the directory and the coldness check).

**The fixture must contain comments that have to survive.** A drill that only supplies violations
cannot distinguish a working check from one that flags everything.

- [x] Point it at a diff containing a changelog above a `const`, a comment restating its line, a test comment naming a finding id and its mechanism, and a long block explaining a non-obvious algorithm. Expected: the first two flagged with their destination named; the last two untouched.
- [x] Run it with no flag on a repo with a dirty tree. Expected: it reports on the diff only, and says so — a run that silently swept the whole repo has broken the default.
- [x] Run `--all` on a real consumer repo. Expected: findings are delivered in a form a person can actually work through, and the report states the total rather than burying it.
- [x] Expected failure mode to watch for: the algorithm block is flagged. Length is not the test; if it fires there, the check has re-derived a cap.

### Drill record — 2026-09-19, **PASS** (4/4, plus D14 and `--all`)

**Runner acquisition.** A separate `claude -p` process (CLI 2.1.276, `--permission-mode acceptEdits`,
`--add-dir` for `~/.claude/skills` and its junction target). **Deliberate deviation from TASK-140's
recipe, stated because it matters:** `--disable-slash-commands` was *not* used. That drill tested whether
a reader applying a rule reaches the right verdict; this one tests whether **the skill works**, so the
runner must be able to invoke it. Coldness here is the brief withholding which comments should go — and
it did: *"Use the review-comments skill on this repo and give me its report."*

**Fixture** — a TypeScript repo with a committed baseline and four comment blocks added as an unstaged
diff, two that must go and two that must survive: a ten-line changelog-plus-QA-log above a `const`; a
two-line comment restating the signature below it; a ~20-line block on banker's rounding, float
representation and the tie test; and a test comment naming FIELD-002 and the mechanism it pins.

| Case | Result |
|---|---|
| changelog above a const → flagged, destination named | **PASS** — 🛑, version history + the ticket |
| restating comment → flagged, destination named | **PASS** — ⚠, the code itself |
| ~20-line algorithm block → untouched | **PASS** — held, *"Length is not a finding"* |
| test comment naming a finding id → untouched | **PASS** — *"A pointer is not a copy"* |
| no flag on a dirty tree reports the diff only, and says so | **PASS** — header names the scope and the file counts |
| the algorithm block flagged for being long (the expected failure) | **did not occur** |

**Three behaviours nobody designed for.** It applied the only-copy rule unprompted, for a reason I had
not thought of: `DEFAULT_RATE` does not exist in `HEAD`, so *"`git log` and `git blame` carry none of
these dates — the destination named by row 2 is currently empty"*, and it refused to delete until the
content is relocated. It applied D12's doc-comment carve-out **in the negative** (line comments are
published nowhere, so no exemption). And it found a real contradiction in the fixture — the comment
claims parity is taken on the digit before the tie while the code tests `floor % 2`, the scaled integer
— then routed it to `/code-review` rather than logging it as a comment finding, which is the axis
separation holding without being told.

**D14's fallback, tested separately and properly.** First attempt removed the rule from the working tree
only; the runner found it at rung 0 anyway and said why — *"if the removal is intentional, commit it and
this skill falls to rung 3"* — which is correct, and meant rung 3 was **not** exercised. Committing the
removal produced: `Comment rule: NOT FOUND in this project — ladder rung 3 (universal floor)`, every
finding prefixed `universal:`, the changelog **downgraded 🛑 → ⚠** by the cap, and the durable fix
recommended. All three guards hold. The drill was more careful than my setup.

**`--all`, run against this repository** — the sharpest fixture available, since `AGENTS.md` blesses
`skills-lint.sh` at 42% comments. Census printed before any finding (10 findings, 6 files, 0/8/2 by
severity), ordering key named with its degeneracy stated (*"density discriminates the first two files;
the last four tie at one finding each and fell to path"*), exclusions on the header with the heuristic
ones marked as heuristics. One batch, under the cap.

**And it found a defect in TASK-141, filed as TASK-151.** `AGENTS.md` § Comments blesses these scripts,
and four findings are inside the file it blesses. The measurement is not wrong about what it measured —
*"on that axis it is right: nothing above is a length finding"* — but it counted lines and read for
rationale, and never ran the test's actual question: does this content live somewhere else? It does: a
superseded figure belonging to version history, and the 8-of-39 measurement in a third copy. The skill's
first real run caught its own author's work from the same day.

## Implementation plan

> **The open question is settled: FEATURE-002 D14.** No rule recorded in the project's guide → read the
> shipped universal copy at runtime, prefix `universal:`, cap at ⚠, project overrides outright. Rejected:
> refusing (useless in most repos, by D5's own consequence) and offering to write the rule first (would
> make this task an ask-step and grow TASK-144's `--unattended` table).

**Deliverable: one file**, `skills/review-comments/SKILL.md`, ~230–260 lines. No `verbs/`, no templates.
Plus both installers re-run (AC8 — state outside the repo).

### The five decisions

1. **Finding the rule — a four-rung ladder, and rung 0 is free.** TASK-147's `comment-rule` markers travel
   into every scaffolded guide, so rung 0 is a machine-exact anchor no heading language can hide:
   markers → a heading naming comments in any language → normative comment prose anywhere → **D14's
   fallback**. Name the rung on the report header. Rung 2 is reachable, not decorative: a repo seeded
   before TASK-147 carries the rule *reworded and unmarked*, which is the failure AGENTS.md § *Universal
   prose ships as a token-free template* measured.
2. **`--all` — census first, then whole-file batches of ≤20 findings, ordered by density then path, and it
   asks nothing.** Asking nothing is load-bearing, not lazy: it keeps this task ask-free, so TASK-144's
   `--unattended` contract grows only by TASK-143's relocation question. The resume line is a printed
   command (`--batch N`), which survives a `/clear`. **20 is labelled a page size, never a threshold** —
   this feature's whole history is a numeral read as a rule.
3. **No language table.** A comment is *a span the language discards*; identify it by reading the file.
   Ship instead: an evidence rule (every finding quotes the text and gives `path:line`, so a
   misidentification is visible in a second), and a false-positive floor — a `//` inside a string, heredoc,
   regex or URL is not a comment; shebangs, pragmas, linter directives and modelines are machinery; markup
   and config files are not swept. **Cannot tell ⇒ do not report.** File selection is `git ls-files`, per
   AGENTS.md § *A repo-level check is answered by what the repo tracks*.
4. **The default diff follows [[verify-conventions]] verbatim** — staged, else working tree, else a named
   range. Two rules it needs and its precedents do not, because a diff gives changed *lines* while this
   check needs a *block*: a comment is in scope when the diff touches any line of it (judge the whole
   block); and **a comment immediately attached to a changed line is in scope even when untouched** — the
   comment the change just made false is the highest-value default finding there is. Bounded deliberately
   at *immediately attached*: a stale block ten lines away is what `--all` is for.
5. **Single file.** The three comparables are single-file (255 / 179 / 352 lines); `verbs/` exists here only
   where a skill has several verbs. With one verb, `SKILL.md` **is** the verb's file, so AC2's operative
   half is the second clause — *a rule that matters to one verb lives with it* — honoured by deference: the
   rule stays in the project's guide, generated-file exclusions stay in verify-conventions, filing stays in
   [[tasks]]. A split would also force the *"see the section above"* across files that AGENTS.md forbids.

### Not written into the file, deliberately — the collisions

| Risk | Handled by |
|---|---|
| TASK-143 must delete a sentence this task wrote | Write the **invariant**, not the current limitation: *never delete the only record* is true before and after 143 lands. Never *"this skill only reports"* |
| Pre-empting 143's question | Write **no question text at all**. `--all` asking nothing keeps the whole task ask-free |
| Claiming TASK-144's wiring | State the axis **rule** (*its own axis, never merged or reranked*) without naming the call site. 144 adds the row in `close.md`; nothing here changes |
| 144's `--unattended` table | This task contributes **zero** rows. Say so in the close notes so 144's author does not hunt for an ask that is not there |
| Check 4's flag contract | Declare both flags with bare tokens in `SKILL.md` — `recv` falls back to `SKILL.md` when there is no verb file (`skills-lint.sh:147-148`, verified). Pass **no** flag to another skill's verb here. Do **not** declare `--unattended`: nothing here can ask, so it would assert an absent capability with no step to govern |
| 143 needing more room | A companion doc (`only-copy.md`, the `INFER.md` pattern), never a `verbs/` directory |

### Risks

- **The fallback is the feature risk.** Label, ⚠ cap and project-overrides-outright are the three guards;
  drop any one and this becomes the adversarial pass D5 declined to build into [[adopt-project]].
- **The attached-comment rule is what the drill actually targets.** Too narrow and the default finds
  nothing; too wide and it silently becomes `--all`, which the drill's second case exists to catch. Write
  it as a named rule, not a description, or two runs will disagree.
- **The runtime pointer to `../new-project/templates/CONVENTIONS-universal.md`** couples this skill to a
  path in another. It resolves in both install roots and lint check 3 pins it here — but a future move
  breaks it at runtime where nothing lints. The alternative, copying the rule, is worse by this repo's own
  rule.

