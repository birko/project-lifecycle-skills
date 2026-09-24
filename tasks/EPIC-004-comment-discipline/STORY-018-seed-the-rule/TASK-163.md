---
id: TASK-163
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-24
depends-on: []
blocks: []
findings: [DRILL-162-1]
pr: null
github-issue: null
jira-key: null
---

# Comment findings the TASK-162 drill surfaced outside its nine

## Context

Found while doing **TASK-162**, by its human test plan: two cold `claude -p --disable-slash-commands`
readers on the whole guide minus the measurement table, over all six scripts. Both confirmed cold (no
skills available). Their reports reached past TASK-162's nine; these five were verified against the tree
on 2026-09-24 and are owned by no existing task.

| Site | Finding | Reader | Verified |
|---|---|---|---|
| `skills-lint-test.sh:313` | *"they differ" sends a reader to diff two files, one of which is empty* — near-verbatim `AGENTS.md` § *Universal prose* (*"because "they differ" sends a reader to diff two files one of which is empty"*) | both | ✅ |
| `skills-lint-test.sh:320-322` | the pin (substring match reports identical copies as differing) earns its place; *"which is what happened the moment this convention was written into AGENTS.md"* is version history | B | ✅ |
| `skills-lint.sh:144-147` | a pointer claiming AGENTS.md § *A format one skill reads is a contract* *"also scopes out the receiver that names a flag only to say it is UNSUPPORTED"* — the word does not appear anywhere in `AGENTS.md`. A pointer at a destination that does not hold the content | A | ✅ (`grep -i unsupported AGENTS.md` is empty) |
| `skills-lint.sh:167-170` | the marker-alone-on-its-line mechanic stays; the clause narrating *when* the substring version failed is history | B | ✅ |
| `skills-lint.sh:291-295` | narrates an earlier implementation (*"gating it on `shadow -eq 0` sent…"*); the test at `skills-lint-test.sh` (`shadow-only root collapses`) carries the same pin | A | ✅ |
| `skills-lint.sh:167-170` (also) | *"a few hundred lines above the block"* — the prose mention is `AGENTS.md:334`, the block `:371`: 37 lines | C, D | ✅ |
| `skills-lint.sh:202-203` | *"every case below unwritable"* — no case follows in this file; the cases are in `skills-lint-test.sh` | D | ✅ |
| `skills-lint.sh:118` | *"Match any `/word verb --flag`"* — the narrower form `AGENTS.md`'s check-4 bullet records as superseded; `ARG_RE` admits arguments between verb and flag | D | ✅ |

**Split, recorded rather than resolved:** `skills-lint-test.sh:313` was reported by both first-round
readers (A, B) and passed by both re-run readers (C, D — D lists `313` among its passes). Take it with
the rest, but it is the weakest row.

**The `:144-147` one is not like the others.** The rest are restatements; this is a pointer that sends a
reader to a section that does not say what it claims. Either the scoping lives somewhere else (find it,
repoint) or it was never written (then the comment is the only copy — relocate before cutting).

## Acceptance criteria

- [x] Each row of the table is acted on or dismissed with a reason recorded.
- [x] `:144-147` resolves one of two ways, stated: repointed at wherever the UNSUPPORTED scoping actually lives, or — if it lives nowhere — the content is relocated to the guide first and the comment becomes a pointer. Never cut as a dangling pointer.
- [x] Every deletion names the destination that holds the content, verified by reading it.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, case count unchanged.

## Out of scope

- The evidence/QA-log blocks at `skills-lint-test.sh:134-180` — **TASK-153**, which already names the neighbouring blocks.
- `skills-lint.sh:219`'s wrong check number — **TASK-081**.
- The `ARG_RE` block — **TASK-141**.
- The `pi-install` headers — **TASK-141**.
- `AGENTS.md` saying "check 5" for install-root drift and 47 cases — **TASK-081** / **TASK-029**.
- Deferred to **TASK-164** — two single-reader, borderline findings from this task's drill (`skills-lint.sh:112-114` ↔ `skills-lint-test.sh:111-112`; `skills-lint-test.sh:346`).
- **Dismissed:** reader F's `install.*` headers restating § Commands — TASK-148 decided those headers keep their one-line mechanism.

## Human test plan

- [x] Two cold readers on the same fixture shape as TASK-162's (whole guide minus the measurement table, all six scripts). Expected: these five not reported (eight — three rows were added at filing, before pick, and this line was not updated); nothing TASK-162 cleared comes back. — **ran 2026-09-24: none of the eight rows reported by either reader, nothing TASK-162 cleared came back.**

### Drill record

**Runner:** `cd <scratchpad>/t163-{e,f} && claude -p --disable-slash-commands --permission-mode plan < t162-brief.txt`
— TASK-162's brief, verbatim and unchanged (recorded there), so the two drills are comparable. Fixture:
`AGENTS.md` minus lines 403-448, all six scripts, outside any git repo. **Coldness:** both listed no skills.

**Result for this task:** none of the eight sites reported. F followed the new `:292` pointer and found it
resolves (*"shadow-only root collapses, precisely"*); E and F both confirmed the TASK-162 pointers at `:41`
and `:68`. One residue in my own rewrite, fixed in-task: E read `:146`'s *"Existence, not semantics"* as a
restatement of `AGENTS.md:279` beside its own pointer — trimmed to the one clause only TASK-082 holds.

**Everything else either reader raised:** already owned (TASK-081, TASK-141, TASK-029), already decided
(the EVIDENCE/PIN lines — TASK-153; the `install.*` headers — TASK-148), or filed as TASK-164 (two
single-reader borderline sites).

**Close gate (2026-09-24), axes side by side:** standards ✅ · fidelity ✅ all four criteria; criterion 2 confirmed — the `:146-147` pointer resolves at TASK-082:36 and :72 · correctness ✅ no executable line changed, all six table rows match, check 5 agrees · comments ✅ no findings. Security: not applicable, comments and prose only.

## Implementation plan

Line numbers as of `123c435`. All edits are comment lines.

| Site | Action | Destination, read 2026-09-24 |
|---|---|---|
| `skills-lint.sh:144-147` | **repoint, don't cut** — the scoping exists, in two places neither of which is the one named: keep the ANCHORED mechanic; the UNSUPPORTED clause becomes *existence, not semantics — a receiver naming a flag only to call it unsupported still satisfies it (TASK-082)* | `AGENTS.md:279` *"Existence only, never semantics"*; TASK-082:36, :72 (the unsupported case, recorded as deliberately not attempted) |
| `skills-lint.sh:118` | `/word verb --flag` → the shape `ARG_RE` actually admits (arguments before the flag) | code, `:135` |
| `skills-lint.sh:167-170` | keep the mechanic (marker alone on its line; a substring match starts at the first *mention*, and AGENTS.md mentions it above the block); cut the when-it-failed narration and the false "few hundred lines" | git (TASK-146) |
| `skills-lint.sh:202-203` | "every case below" → the install-root cases in `skills-lint-test.sh` | the test file |
| `skills-lint.sh:291-295` | keep *why* the collapse ignores shadows (the contradiction is fixed in the wording); cut the narration of the earlier gate; point at the pin | `skills-lint-test.sh` `shadow-only root collapses` + its comment; TASK-037 |
| `skills-lint-test.sh:310` | one-line pointer (split 2:2 → the rule's own row: guide content ⇒ delete or pointer) | `AGENTS.md` § *Universal prose*, *"they differ" sends a reader…* |
| `skills-lint-test.sh:317-319` | cut the trailing history clause; the pin stays | git (TASK-146) |

Then: both suites (56, lint exit 0), re-measure the AGENTS.md table (both scripts change), set both verdicts
to what is true after this task, and run the human test plan.
