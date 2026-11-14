---
id: TASK-085
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [VC-027-1, CR-7, SH-53, SH-55]
pr: null
github-issue: null
jira-key: null
---

# `LAYER.md`'s survey-state list has outgrown the shape it is written in

## Context

**Spawned from TASK-027's close gate on 2026-08-31** (`/verify-conventions`, 💡).

`LAYER.md` § *Report the state precisely* is a bullet list of **eight** survey states. Each bullet now
carries the state's definition, its probe, its claimability guard, its interactions with other states, and
a worked example — and the `present, uncommitted` bullet reached **~350 words in a single bullet** after
TASK-027 (which lengthened an already-long one, so this is partly that task's doing and is filed rather
than hidden).

`AGENTS.md` § Conventions › Output/prose rules says: *"Tables and short lists beat paragraphs for anything
an agent must branch on. Reserve prose for the why."* The states **are** a branch — an agent picks exactly
one per artifact — and they are currently the longest prose in the file.

**Why this is filed at P3 and not treated as urgent.** No behaviour is wrong. Every bullet is individually
correct, and TASK-027 put the branch on its own bolded line precisely so the rule is readable ahead of the
rationale. This is a readability trajectory, not a defect: the list has gained states steadily (the file
itself says it *"grows as real repos turn up conditions it cannot yet express"*), and a growing branch list
written as prose bullets is exactly the shape the convention warns about.

**Do not assume the answer is a table.** The bullets carry genuinely different *kinds* of content, and a
table with a 350-word cell is worse than the bullet it replaced. Shapes worth weighing: a compact
decision table (state · when it applies · what it suppresses) with the rationale moved below as named
subsections; or leaving the list and extracting only the probes. **The risk to respect is that every
consumer reads this file**, so a reshape that loses a guard — `present, outdated`'s *claim it only where
something can tell you*, or `not applicable yet`'s lazy-row-only restriction — trades a readability win
for a correctness loss. That is the real constraint, not the formatting.

### Merged in 2026-09-26: TASK-112 — The adopter's report list gained no entry for the `not applicable` state

_Merged because restructuring LAYER.md's survey states fixes the report list's missing `not applicable` entry in the same edit. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-112.md`._

**From a [[code-review]] pass on 2026-09-08.**

`skills/adopt-project/SKILL.md:362`'s per-state report list covers `not applicable yet` — the `(lazy)`
state — but has no entry for **`not applicable`**, the settled state the conditional rows introduced.
The paragraph above it claims to cover *"the states that exist today"*, so the omission reads as a
statement that the state does not exist.

`AGENTS.md` is explicit that the two must not be collapsed: *"a library does not acquire a `Dockerfile`
by aging, so one state is settled and the other is pending, and collapsing them loses whether anyone
should look again."* A report list that names only the pending one invites exactly that collapse.

**Filed P3 deliberately.** The generic catch-all rule at `:350` does cover the state, so the adopter
will not misreport it — the defect is that the list contradicts the paragraph introducing it, and a
reader trusting the list over the catch-all gets it wrong.

#### Note added 2026-09-17 by TASK-138 — the entry now has two sub-cases

[[TASK-138]] made `not applicable` reachable by two different routes, and the scaffolder's closing
checklist now distinguishes them: a No **declared** (the user or the repo said so) stays silent, while a
No **derived** by classifying components gets a line naming what carried it — because a derived No is the
only state that is otherwise invisible, `not applicable` being settled and therefore suppressing the fill,
the offer and any re-ask.

**Not folded into this task** — that is the scaffolder's reporting surface and this is the adopter's. But
when this task adds the missing `not applicable` entry, the entry should carry the same split rather than
a single line, or the two front doors will describe one state in two different shapes. See
`skills/new-project/LAYER.md` § *Conditional rows*, the No-direction table.

### Linked 2026-10-04: SH-53 and SH-55, from the project-baseline spec harvest (EPIC-007, TASK-080)

- **SH-53 — the state count is stale.** LAYER.md § *Detect what the repo has* now has **nine** state bullets
  (present, present uncommitted, present outdated, present elsewhere, unknown, missing, missing not offered, not
  applicable, not applicable yet). The paragraph under "Two things reach unknown" still says "The list is already
  eight states" and "not a ninth state", which contradicts the same section's own "the number of them does not
  [matter]". Whatever shape this task chooses, it should drop the number rather than update it.
- **SH-55 — the adopter's missing `not applicable` entry is still open, and LAYER.md points at the wrong task.**
  This is the merged TASK-112 finding, re-confirmed at `adc4c27`: `adopt-project/SKILL.md`'s report list still has no
  entry for it. LAYER.md § *Conditional rows* still says "see TASK-112", a cancelled task. The pointer should name
  this one, or nothing once the entry exists.

## Acceptance criteria

- [x] An agent can determine which state applies to an artifact without reading a paragraph per state
- [x] Every guard, suppression rule and claimability restriction currently attached to a state survives verbatim in meaning — enumerate them before and after and show none was dropped
- [x] The rationale is still present, not deleted for brevity — the *why* is what stops a state being claimed wrongly
- [x] `new-project` and `adopt-project` both still resolve every state they reference (layer parity)
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-112* (the four entry criteria met by TASK-353, 2026-11-13: `adopt-project` step 4 gained the `not applicable` entry. Its lint line is this task's own):

- [x] The report list carries `not applicable` with its own line, distinct from `not applicable yet`
- [x] The distinction is visible in the wording, not just the label — a reader can tell settled from
      pending without consulting `LAYER.md`
- [x] The list and the paragraph that introduces it agree about which states exist
- [x] Nothing restates `LAYER.md`'s state definitions — the list points, it does not copy
- [x] `bash .github/workflows/skills-lint.sh` passes

*From SH-53 and SH-55:*

- [x] LAYER.md states no count of its survey states
- [x] LAYER.md § *Conditional rows* no longer points at the cancelled TASK-112 (met by TASK-353, 2026-11-13)

## Out of scope

- Adding, removing or redefining any state. This is the shape the list is written in, not its content — a change to the content is a different task with a different review.
- The rest of `LAYER.md`. If the row table has the same problem it is its own task.

*From TASK-112:*

- The state definitions themselves — `LAYER.md` § *Conditional rows* owns them.
- The `unknown` state and the frontier-round question — TASK-097 owns that.

## Human test plan

- [x] Hand the reshaped section to a reader who has not seen it and ask them to classify three artifacts (one present, one staged-but-uncommitted, one lazy-and-absent); confirm they reach the right state without reading the whole section
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d085` (`claude -p --disable-slash-commands`, cwd holding only
    `skill/` at the fix and `brief.txt`; the runner listed no skills). All three right: `present` and `not applicable yet`
    from the table alone, `present, uncommitted` (`A  tasks/.config.yml`) from the table, confirmed in one subsection.
- [x] Diff the guard inventory before and after and confirm it is unchanged
  - **Passed 2026-11-14**: 26 guards enumerated across the ten states (the claimability limits, the suppressions,
    the carve-outs, the composition) and each searched for in HEAD's and the fix's text. All 26 are present in both,
    one differing only in the capital letter its subsection now opens with. A scripted check also confirmed every
    state's full text survives word for word, in order.

*From TASK-112:*

- [x] Run the adopter's survey over a library with no `Dockerfile` and read the report. Expected: the
      row reports `not applicable`, and the report's own legend explains it without sending the reader
      elsewhere.
  - **Passed 2026-11-14**, as d085's case 4, by the classification rather than a full adoption run: the runner reached
    `not applicable` from the table and one subsection, and from `adopt-project` step 4's list printed a derived-No
    line, `Dockerfile — derived No: a library, one package, no entry point, nothing deployed`, under no gap heading.

## Implementation plan

Inline: a decision table at the head of the list, each bullet becomes a subsection under its state's name with its text unchanged, and the count goes.

## Outcome

**The shape (`skills/new-project/LAYER.md` § *Detect what the repo has*).**
- **The table.** *Report the state precisely* now opens with a decision table: state, applies when, what it suppresses
  or adds, and claim it only where. An agent picks its row there.
- **The subsections.** Each former bullet is a `### <state>` subsection beneath the table, its text kept word for word
  (only the first letter capitalised), and the table says a subsection wins wherever the table is shorter.
- **The paragraphs that follow** sit under a new `### Reading the states together` heading, so they no longer read as
  part of the last state.
- **Unchanged:** every `§ *Detect what the repo has*` link still resolves, since the states are subsections of it.

**Not a table of 350-word cells.** The table carries only what the branch needs; the probe, the measured cases and the
reasons stay in prose under each state, as the task's context warned.

**SH-53:** the count is gone: "not a ninth state" now reads "not another state", and "already eight states" became
"states". **SH-55 and the TASK-112 criteria** were met by TASK-353.

**One-runner reading left unfiled** (FEATURE-002 D10): d085 case 4 asked whether a README calling the repo "a library"
is the repo *declaring* the No (silent) or evidence for a derived one (a line). `adopt-project` step 4 does not define
"the repo declares".

**Close gate (inline; one skill file plus a restamp):**
- **Standards:** a table for the branch and prose for the why, per *Tables and short lists beat paragraphs*.
- **Intent:** all criteria met; no state was added, removed or redefined.
- **Correctness:** d085, and the guard inventory.
- **Layer parity:** `new-project` and `adopt-project` reference states by name and the section by its heading, and
  both still resolve.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** project-baseline is restamped with no content change, since no requirement moved.

## Progress log

- step 2 — picked; ranked above TASK-261 because every consumer of both front doors reads this section to classify every artifact, where TASK-261 weighs folding three help files; STORY-012 already in-progress
- step 3 — re-verified: ten states as prose bullets, the longest several hundred words; "eight states" and "a ninth state" still in the text; TASK-112's criteria met by TASK-353
- step 5 — reshaped: decision table plus one subsection per state, text unchanged; count dropped
- step 6 — behavioural: d085 (four cases right, two from the table alone); guard inventory 26/26
- step 7 — project-baseline restamped, no content change
- step 8 — closed inline; commit in git log
