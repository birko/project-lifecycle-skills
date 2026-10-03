---
id: TASK-208
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-02
depends-on: []
blocks: [TASK-205, TASK-209]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-007]
pr: null
github-issue: null
jira-key: null
---

# The migration writes "reason unknown" over a block reason the file already states

## Context

Found while running TASK-205's human test plan (2026-10-02) against Symbio's migration branch,
`tasks/status-migration` at `888af6dc` (PR BirkoWorks/Symbio#1, open, not merged). Of the 12 tasks the
migration rewrote, 4 got `blocked: reason unknown` although the old file stated why it was blocked.

The reason ladder is `skills/tasks/verbs/init.md` step 3b, the **Reason** bullet. It tries, in order:
a `> Blocked <date> — <reason>` note (read through emphasis), then unmet `depends-on`, then
`reason unknown`. The four files hold their reason in shapes the ladder does not try:

| Symbio task | Where the reason is on `main` | Why the ladder missed it |
|---|---|---|
| TASK-358 | the `status: blocked  # ⚠ …` comment, and `> **BLOCKED 2026-08-08 — awaiting a commercial decision, deliberately.**` in the body | the note is upper-case `BLOCKED`; the status-line comment is dropped by the anchored read (the leon fix in TASK-205) |
| TASK-068 | `status: blocked  # ⏸ DEFERRED 2026-09-19 by the user until Booking is real work …`, continued over several `#` lines | the status-line comment is never a reason source |
| TASK-305 | body line `🚫 **Blocked — no PostgreSQL, MSSQL, MySQL or ElasticSearch instance exists on this machine** …` | not a `>` note and carries no date |
| TASK-273 | body heading `## DEFERRED 2026-07-28 — there is no environment to rotate yet` | a heading, and the word is `DEFERRED` |

The anchored read of `status:` is right for the **value** and must stay; the defect is that the
comment it discards was, in two of these files, the only place the reason was written. DraCode (24
blocked, all reasons from `depends-on`) is unaffected, which is why one repo of the two checked passed.

## Acceptance criteria

- [x] Step 3b's reason ladder finds a reason stated in each of the four shapes above: a comment on the
      `status: blocked` line (including its `#`-continuation lines), an upper-case `BLOCKED` note, a bold
      `Blocked —` line that is not a `>` note, and a `## DEFERRED <date> — <reason>` / `## BLOCKED …` heading
- [x] The order of the ladder is stated, and `block`'s own `> Blocked <date> —` note still wins when present
- [x] A long reason is cut to one line in the `blocked:` field, and the field says where the full text is,
      rather than copying a paragraph into frontmatter
- [x] `reason unknown` is still written when a file states no reason in any shape — the fix must not
      promote unrelated prose (a "blocks:" line, a mention of another task being blocked) into a reason
- [x] Symbio's migration branch is re-run with the fixed step and the four tasks carry their real reason;
      the other 8 are unchanged
- [x] The `blocked:` line is written after the `status:` line **and** its indented `#` continuation lines,
      never between them (added 2026-10-02 at planning, by the owner's choice: Symbio's TASK-068 had its
      status comment split in two)
- [x] Regression check: a case the lint or its tests can pin, if the reason ladder is checkable there; if it
      is prose-only, the four Symbio files are recorded as the drill fixture, with the expected reason for each

## Out of scope

- Re-migrating the other repos — DraCode, WorkoutTracker and Birko.Framework reasons were checked or
  came from `depends-on`; only re-run one if a check shows the same defect there
- Presenter, still skipped for the reason recorded on TASK-205
- Deferred to TASK-209 — seven older edge cases in the blocked-field writers raised by this close's correctness pass (resolved notes, cancelled dependencies, a `done` prior state, `block.md`'s placement, mixed-form files, the fallback's field, tie-breaks)

## Human test plan

- [x] On Symbio's `tasks/status-migration` branch after the re-run, `/tasks show` TASK-358, TASK-068,
      TASK-305 and TASK-273: each `blocked:` reason says what the old file said, in one line
- Not a step of this task (rewritten from a checkbox at close, 2026-10-03): the owner's `/tasks` check in DraCode and Symbio
  is TASK-205's own human test plan, and is signed off there once TASK-205 is unblocked.

### Drill fixture (the expected answers — never give these to a runner)

Symbio pinned to `890b9987` (the merge-base of `main` and `tasks/status-migration`); old files read with
`git show 890b9987:<path>`, the current migrated ones at `888af6dc`. **The four positives are contaminated**
— the change was justified by them, so a pass is weak evidence and a fail is decisive.

| File | Expected rung | Expected `blocked:` |
|---|---|---|
| TASK-358 | note | `awaiting a commercial decision, deliberately` |
| TASK-068 | judgement (status comment) | `DEFERRED 2026-09-19 by the user until Booking is real work (full text in the status comment)` |
| TASK-305 | judgement (bold line) | `no PostgreSQL, MSSQL, MySQL or ElasticSearch instance exists on this machine` |
| TASK-273 | judgement (heading) | `there is no environment to rotate yet` |
| TASK-461, -377, -380, -435, -729, -831, -257, -450 | unchanged | byte-identical to `888af6dc` |
| WorkoutTracker `366959b^` TASK-180 | none | `reason unknown` (uncontaminated) |
| WorkoutTracker `366959b^` TASK-168 | depends-on | `waiting on TASK-072` |

Near-misses no run may pick: listed in the implementation plan's *Measured* table. Two independent cold runs
must agree on every row.

## Implementation plan

> Acceptance criteria questions, answered by the owner 2026-10-02:
> (1) **Placement** — TASK-068's `blocked:` line splits its multi-line status comment, because step 3b says
> "the line after `status:`". **Fixed here**; a criterion was added.
> (2) **Drill fixture** — a pass on the four Symbio files is weak evidence, since the change is justified by
> that repo (`skills/populate-tests/SKILL.md` § *Choosing a target*). **Accepted as enough**, with the
> near-misses and WorkoutTracker TASK-180 as uncontaminated negatives.

### Measured (read-only)

- Symbio `main` 890b9987, branch `tasks/status-migration` 888af6dc. **7 of the 8 correct files carry a
  `status:` comment** (TASK-461, -377, -380, -435, -729, -831, -450), with reasons from `depends-on` (TASK-450
  from its `> **Blocked …**` note). So the status-comment rung must sit **after** `depends-on`, or criterion 5
  fails.
- Near-misses that must not match:

  | File | Line | Must not match because |
  |---|---|---|
  | TASK-377 | `⚠ **H1 DEFERRED 2026-08-20, not judged — …**` | bold, but does not open with `Blocked` |
  | TASK-257 | `## Status — partially delivered; the paging half is BLOCKED (2026-07-27)` | the word is not first in the heading |
  | TASK-257 | list item `… → **BLOCKED, but the full-table reads are gone.**` | a list item, no dash |
  | TASK-068 | `## Deferral 2026-09-19 — and the measurement …` | `Deferral` ≠ `DEFERRED` |
  | TASK-358 | `> **What is genuinely blocked by this:**` | a `>` note not opening with the word |
  | TASK-358 | `**TASK-006** … is blocked on this` | another task being blocked |
  | TASK-358 | `depends-on: []  # ⚠ …` | a comment on a field other than `status:` |
  | TASK-461 | `*(blocked on Phase 3)*` | italic, lower case, parenthesised |
  | TASK-273 | `# 1. …` lines | inside a code fence |

- DraCode (`35f9e5c^`), WorkoutTracker (`366959b`) and Birko.Framework TASK-148: the new ladder gives the same
  reasons. WorkoutTracker TASK-180 correctly stays `reason unknown` (an uncontaminated negative).

### Expected `blocked:` lines (oracle, fixed before the run)

| Task | Rung | Expected line |
|---|---|---|
| TASK-358 | 1 `>` note (upper-case `BLOCKED`) | `blocked: awaiting a commercial decision, deliberately` |
| TASK-068 | 3 status comment, cut | `blocked: DEFERRED 2026-09-19 by the user until Booking is real work (full text in the status comment)` |
| TASK-305 | 3 bold line | `blocked: no PostgreSQL, MSSQL, MySQL or ElasticSearch instance exists on this machine` |
| TASK-273 | 3 heading | `blocked: there is no environment to rotate yet` |

The other 8 stay byte-identical to 888af6dc.

### Steps

_Grilled 2026-10-02 (owner): the closed list of shapes drafted first was replaced by one judgement rung;
order, field content and evidence settled. Resolved decisions are the four bullets at the end of this plan._

1. **Rewrite the Reason bullet of `skills/tasks/verbs/init.md` step 3b as a table**, first match wins, one
   line of why per rung:

   | # | Source | Reason taken |
   |---|---|---|
   | 1 | newest `>` note whose text, read through emphasis, opens `Blocked <date> —`, any case (`block` writes it, so it wins) | as today |
   | 2 | unmet `depends-on` | `waiting on TASK-X, TASK-Y` |
   | 3 | **judgement:** the sentence anywhere in the file — body, heading, or the comment on the `status:` line and its indented `#` continuation lines — that states why **this** task is currently held | the source's own words, rung 3's rule below |
   | 4 | `reason unknown` | — |

   Rung 3 must **quote the source line verbatim with its line number in the report**, which is what makes a
   judgement checkable. It rejects: a negation ("NOT blocked by …"), another task's block, a block stated as
   resolved, a partial-scope remark not opening with the block word, text inside a code fence, a vocabulary
   legend, a comment on any field but `status:`. Several candidates → newest date, else first in the file.
   Rung 3 after 2 because `depends-on` is mechanical and already right for 32 measured tasks; judgement runs
   only where nothing mechanical answered. **Every example string in `init.md` is invented**, so the drill's
   negatives stay uncontaminated.
2. **Rung 3's field rule:** the source's own words, never a summary, cut at the first ` — `, `;` or sentence
   end and at most 120 characters; when text was dropped append
   ` (full text in <the status comment | § <heading> | the note of <date> | the "Blocked" line>)` — a place,
   never a line number. Quote the value when it contains `: ` or ` #` or opens with a YAML indicator.
3. **Placement** — after the status line *and* its continuation lines (pending question 1).
4. **Report** names the rung per file (`note | depends-on | judgement | none`), and for judgement the quoted
   source line and its line number.
   `block.md`, `SKILL.md`, `audit.md` unchanged.
5. **Lint** — run both scripts. **No new lint case:** nothing in the repo executes the ladder, a bash copy
   would test itself, and a wording grep passes while the prose is wrong. Criterion 6 takes its prose-only
   arm (step 6).
6. **Record the fixture here**, under the human test plan (never in `init.md`): Symbio pinned to 890b9987,
   the four positives with expected lines, the 8 unchanged, the near-misses, WorkoutTracker TASK-180; the four
   positives marked contaminated.
7. **Re-run on Symbio without touching its main copy.** Re-running `init` on the branch tip is a no-op
   (idempotent), so rebuild the 12 files from their old form in a separate worktree:
   `git worktree add <outside>/Symbio-TASK-208 tasks/status-migration`, then
   `git checkout <merge-base> -- <the 12 paths>`. Run step 3b with **two independent cold runners** (record
   command, cwd, coldness check for each) on copies of the same rebuilt files, supplying only TASK-205's
   recorded prior-state answers (TASK-305 in-progress; TASK-729, TASK-831 todo), executing step 3b only.
   All 12 `blocked:` lines must agree between the runs and no near-miss may be picked; a disagreement is a
   prose defect — tighten rung 3 and repeat both. Commit the first run's output: `git diff` against 888af6dc
   must show only the four `blocked:` lines (plus TASK-068's move). Commit those four files only. **Owner's go-ahead before pushing**; then a
   plain push to `tasks/status-migration` and a PR #1 comment. `git worktree remove`, never forced.
8. **Fresh negative, in both runs:** a scratch clone of WorkoutTracker at `366959b^`, nothing committed —
   TASK-180 must stay `reason unknown`, TASK-168 `waiting on TASK-072`.
9. `/tasks close TASK-208`; then re-run TASK-205's check on Symbio and `/tasks unblock TASK-205`.

### Risks

- Judgement after `depends-on` means TASK-729's richer comment loses to `waiting on TASK-001` — accepted,
  forced by criterion 5.
- Judgement can pick the wrong sentence (TASK-358's comment says "NOT blocked by TASK-009"; TASK-377 has
  "H1 DEFERRED, not judged"). The verbatim quote in the report and the two-run agreement are the mitigation.
- Earlier-migrated repos are not repaired by re-running `init` (idempotence). Only Symbio needs it.
- Another session works in Symbio: only `worktree add`/`remove` touch its `.git`; no checkout, no push
  without the owner.

### Resolved decisions (grill, 2026-10-02)

- How the reason is found → note and `depends-on` stay mechanical; the other shapes become one judgement
  rung that quotes its source line (a closed shape list trails every new repo; the quote keeps it checkable)
- Order → note → `depends-on` → judgement → `reason unknown` (keeps the 8 correct files unchanged)
- Field content → verbatim, cut at a natural break, ≤120 characters, pointer names a place (a summary
  invents a reason; line numbers go stale)
- Evidence → two independent cold runs plus WorkoutTracker `366959b^`; every line agrees, no near-miss
  picked, disagreement = prose defect (FEATURE-002 D10's two-reader bar)

## Progress log

- 2026-10-02 — Picked. Plan drafted and grilled; two acceptance-criteria questions answered by the owner (placement criterion added; Symbio fixture accepted with fresh negatives).
- 2026-10-02 — `init.md` step 3b rewritten: reason ladder note → depends-on → judgement → `reason unknown`; placement after continuation lines; rung named in the report. Lint OK. Fixture recorded under the human test plan.
- 2026-10-02 — Drill set up: two sandboxes under `%TEMP%\d208a|b`, each with a detached Symbio worktree at `890b9987` and a WorkoutTracker worktree at `366959b^` (`b956019`), plus a copy of `SKILL.md`, `init.md`, `block.md`. Runners: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" Read Edit Grep Glob < d208brief.txt`, cwd the sandbox, run concurrently.
- 2026-10-02 — Runner B done (coldness: no skills listed, no prior exposure; CLAUDE.md of both trees auto-injected). Against the oracle: 358, 068 match; 8 depends-on/note files match apart from a trailing period on 450 (`… elsewhere.` vs `… elsewhere`); **305 and 273 fail** — the cut at the first ` — ` left only the label (`Blocked`, `DEFERRED 2026-07-28`); **WT TASK-180 fails** — a priority-downgrade note was promoted to a reason (expected `reason unknown`). Runner also flagged: rung 1 does not say where a note's reason ends; the tie-break date is unscoped; neither named history read was runnable under its permissions.
- 2026-10-02 — Runner A done (cold: no skills listed, no prior exposure). Disagreed with B on 3 of 14 lines (358 and 450 pointer/period, TASK-180 a different wrong pick); same two failures on 305 and 273. Round 1 reports kept at `%TEMP%\d208round1`. Prose round 2 in `init.md`: drop the label before the dash; one unit (rest of a bold span, else to the first break); drop the trailing full stop; pointer only when the reason itself was cut; rung 3 excludes titles, priority/classification changes, verdicts about the defect, and unblock conditions; a sentence does not inherit a date; any equivalent history read allowed. Sandboxes restored; both runners re-run cold.
- 2026-10-02 — Round 2. Runner A's first attempt was aborted by an API safeguard error after 3 edits (req_011CfdLa1tDzRQmxuKW5Atny) — a harness failure, discarded; sandbox restored and A re-run. Runner B (cold): **all 14 lines match the oracle**, 13 written, TASK-273's edit blocked by a safety classifier (the file is about rotating a leaked secret) with its intended line reported as `there is no environment to rotate yet`, matching. TASK-180 → `reason unknown`. B flagged one residual ambiguity: whether a ` — ` cut in a non-bold source is "reason" (pointer) or "commentary" (none); it followed the invented example (pointer), which matches the oracle for TASK-068.
- 2026-10-02 — Round 2 runner A (re-run, cold: no skills listed, no prior exposure): **all 14 lines match the oracle and agree with B** on every line B wrote. Both readers flagged the same two gaps (pointer after a plain ` — ` cut; which words are block words), each resolved the same, correct way — written into `init.md` as stated rules, plus `<reason>` in the history question defined; no third round, since the sentences codify what both runs did. Compared with the PR branch ignoring CRLF (sandbox `core.autocrlf=true`): 8 files identical, 4 change only their `blocked:` line, TASK-068's moves below its comment. Committed on `tasks/status-migration` in a separate worktree (`%TEMP%\d208pr`) as `9c0eb879`, 4 files, 4+/4−. **Not pushed — waiting on the owner.** Criterion 6 took its prose-only arm: no lint case (nothing in the repo executes the ladder); the fixture is the drill record above.
- 2026-10-02 — Owner approved the push: `888af6dc..9c0eb879` to `origin tasks/status-migration` (fast-forward), PR #1 commented. Read back from the pushed branch: the four tasks carry the expected reasons, TASK-068's line sits after its comment, 13 blocked (8 todo, 3 verify, 2 in-progress), no old form, 0 `reason unknown`. Human test plan step 1 run by the agent on the pushed branch. Temporary worktrees removed with `git worktree remove`; drill reports kept at `%TEMP%\d208round1` and `%TEMP%\d208round2`. PR #1 is mergeable (CLEAN) and not merged — merging is Symbio's own step.
- 2026-10-03 — On the owner's instruction, PR BirkoWorks/Symbio#1 merged (merge commit `c9531dfa`, guarded by `--match-head-commit 9c0eb879`) after checking: only the 12 task files, no CI configured, `origin/main` unmoved since the merge-base, no overlap with the 18 unpushed commits on Symbio's local `main`. Branch deleted locally (`git branch -d`) and on origin. Symbio's main copy was not touched; its local `main` (another session's, 18 ahead) now also needs the merge from `origin/main`.
- 2026-10-03 — Close, step 5b. **Intent:** pass — 7/7 criteria met; two unrequested additions, both explained (the alternative history read, from round 1's permissions; the rung named in the report, from the grill) — recorded here rather than as criteria added after the fact. **Correctness:** 10 findings. Fixed here, being about the text this task wrote: the example vs the unblock-condition exclusion (CR #1), the quoting rule (single quotes, trailing `:`, non-string scalars, quote last; #6), label-only and cross-reference sources fall through, continuation lines joined, sentence end defined, symbol drop never eats `#NNN`/`@name` (#8 part), `<reason>` unquoted (#9). Spawned as TASK-209 (CR-132–CR-138): seven older edge cases in the blocked-field writers. **Standards:** pass with warnings — both applied (rung 3 rules as a list, the pointer rule as step 4) plus the imperative wording and the example's half-sentence; the `block.md` format-contract note went to TASK-209. **Security:** not applicable — skill prose only, no auth, data, input or secrets surface. **Comments:** not applicable — no code comments in range. Because the close changed the drilled prose, round 3: two fresh cold runs (sandboxes `d208c`, `d208d`) on the shipped text.
- 2026-10-03 — Round 3, on the text as shipped (runners C and D, cold: no skills listed, no prior exposure): **both match the oracle on all 14 lines and agree with each other.** Both raised the unstated order of ids in rung 2 → stated (`in depends-on order`, which both used). Raised by one reader only, recorded and not acted on (FEATURE-002 D10): rung 1 has no content filter (TASK-450's note reads as a status summary); legend lines carrying the old vocabulary are not rewritten; a `depends-on` line's own trailing comment; whether `Deferral` is a block word. Reports at `%TEMP%\d208round3`; sandboxes removed.
- 2026-10-03 — Out-of-scope sweep: 3 boundaries (other repos, Presenter, TASK-209), 0 spawned here beyond TASK-209, 0 declined. Closed `done` (single-branch: done = on main).
