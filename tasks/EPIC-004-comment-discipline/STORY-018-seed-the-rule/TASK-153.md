---
id: TASK-153
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-151-1]
pr: null
github-issue: null
jira-key: null
---

# The 8-of-39 measurement has a fifth copy, in the test that pins it

## Context

Found while doing **TASK-151**, whose criterion 4 required walking every comment block in this repo's
six scripts and asking the rule's actual question — *delete the line, then search for where its
content already lives*. TASK-151's own table named four copies of the check-4 measurement; the walk
found a fifth it did not know about.

`.github/workflows/skills-lint-test.sh:137-140`:

> `# An ARGUMENT between the verb and its flag. The check matched only `/skill verb --flag`, so every`
> `# invocation carrying an id, a placeholder or a subcommand first was invisible — measured at 8 of 39`
> `# real invocations (~20%) on this repo, including `/tasks move <ids> --to`, added by the same epic`
> `# that wrote this suite. These two are EVIDENCE, not pins: the first passes against the old lint.`

**Destination: the ticket.** TASK-108 carries the same measurement at `:39`, `:114` and `:172`, and
`AGENTS.md:279` carries it again. TASK-151 reduced the sixth copy — `skills-lint.sh:124-128` — to a
pointer at TASK-108; this one was left because it sits outside TASK-151's four named sites and taking
it would have widened an in-flight task.

**Why this is genuinely borderline, and must not be swept without thought.** The comment rule
explicitly protects *"a test comment naming the finding it pins and the mechanism it proves"* — so a
comment here **should** name its finding. The question is only whether *naming* it requires
reproducing the number, or whether `TASK-108`'s id does the naming. The sentence that must survive
either way is the last one: **these two cases are EVIDENCE, not contract pins** — the first passes
against the old lint — and that distinction lives nowhere else in the file.

`:157-160` and `:182-186` are the neighbouring blocks and make the same evidence/pin distinction
without quoting a measurement; they are the shape this one should probably take.

## Acceptance criteria

- [x] `skills-lint-test.sh:137-140` either points at TASK-108 for the measurement, or keeps it with a recorded reason. "Left as is" alone does not close this.
- [x] Whichever way it goes, the EVIDENCE-not-pin distinction survives in full — it is the half that lives nowhere else.
- [x] The three blocks at `:137-140`, `:157-160` and `:182-186` end up consistent with each other about how much of a finding a test comment restates. A fix to one that leaves the other two in a different style is a half-fix.
- [x] `AGENTS.md` § Comments' verdict row for `skills-lint-test.sh` is updated to match the outcome.
- [x] `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh` both pass.

## Out of scope

- The other four copies — TASK-108 and `AGENTS.md:279` own those, and TASK-151 already reduced `skills-lint.sh`'s.
- `pi-install.sh` / `install.sh` and their ADR-overlapping why-clause — **TASK-148** owns that.
- The comment rule's wording — settled, FEATURE-002 D1/D2.
- `:310` and `:317-319` (reported again by this task's `/review-comments` run) — **TASK-163**.
- `AGENTS.md` § Comments saying `skills-lint.sh`'s longest block "survives at 30 lines" while the table beside it says 26 — the table's prose, owned by **TASK-141**'s re-run with the rest of the verdicts.

## Human test plan

- [x] Run `/review-comments --all` and confirm this site is no longer reported, or is reported and the recorded reason explains why it stands. — **ran 2026-09-24 as the `PATH` scope on the file** (a whole-file sweep, which covers this site; `--all` would add five files outside the task). `:133-135` not reported. One new finding **inside a rewritten block** — `m_flagprose` kept the fatal-check rationale TASK-108:126-127 holds — cut to a pointer. The other two findings are TASK-163's.
- [x] Read the four blocks in sequence. Expected: a reader cannot tell which was edited — they answer "why does this case exist" the same way. — **ran, two cold readers; see record. Residual differences argued by-design below; accepted by František Bereň 2026-09-24.**

### Drill record

**Runner:** `cd <scratchpad>/t153[b] && claude -p --disable-slash-commands --permission-mode plan < t153-brief.txt`.
Fixture: `skills-lint-test.sh:130-190` alone, as `excerpt.sh` — no guide, so the reader judges consistency
and not rule compliance. **Coldness:** both listed no skills. Brief (verbatim):

> First, list every skill or slash command available to you in this session, or say plainly that there are none.
>
> excerpt.sh in this directory is a slice of a shell test suite for a lint script. It contains several test fixtures (functions named m_*), each preceded by a comment block. Read the comment blocks only.
>
> 1. For each comment block, say in one line what question it answers about the fixture below it.
> 2. Do all the blocks answer "why does this case exist" in the same way — same parts, same order, same kind of labels? Name any block whose style differs from the others, and how.
> 3. Does any block narrate history (how the case came to be) or quote a measurement, rather than saying what the case pins?
> Do not edit any file.

**Round 1 → fixed:** block 3 opened with a rule instead of the `<CAPS THING>:` lead; block 1 covered two
fixtures without saying so (block 4 does); block 1's "hid" was past tense.
**Round 2 → fixed:** "previous lint" vs "old lint"; "two README.md.tmpl files" carried a count that rots.

**Round 2 → left, with the reason** (the part a human should confirm):

| Reader's point | Why it stands |
|---|---|
| block 4 says `PIN`, the rest `EVIDENCE` | the distinction the file exists to carry — criterion 2 |
| fixture-shape notes on blocks 2 and 3 only | the plan's part 3 applies only where a simpler fixture silently stops reproducing; blocks 1 and 4 have no such trap |
| block 3's evidence is against an over-wide `ARG_RE`, not the old lint | a false-positive guard's evidence *is* the wrong widening; named as such in the block |
| every EVIDENCE/PIN line "records a past experiment" | that record is what tells evidence from pin; removing it deletes the only copy |

Both runs: no block quotes a measurement any more; `8 of 39` now lives only at TASK-108 and `AGENTS.md:279`.

## Implementation plan

⚠ Scope, stated before work: **a fourth block joins the three.** `:165-169` (`m_flagprose`) sits
between them, makes the same evidence/pin claim, and was reported by three of TASK-162's four readers
(a QA log: *"Verified against a bare-word ARG_RE…"*). TASK-163's Out of scope sends `:134-180` here.
Criterion 3's "consistent with each other" cannot hold if one of four neighbours keeps a different
style, so it is taken in the same pass rather than spawned.

Line numbers are as of `bae4dc5` (shifted −4 by TASK-162): `:133-136`, `:153-156`, `:165-169`, `:178-182`.

**The one shape all four take** — three parts, nothing else:
1. **what the case pins** — the mechanism that was blind, in present tense;
2. **`EVIDENCE:` or `PIN:`** — whether the case fails against the lint before its fix, in one clause,
   because that is the distinction the file carries and nothing else does;
3. **why the fixture has its shape**, only where a simpler fixture would silently stop reproducing it.

Out: measurements (TASK-108 / `AGENTS.md:279`), and narration of how the case came to be (git).

| Block | Keeps | Cuts → destination |
|---|---|---|
| `:133-136` argument | pins: an id/placeholder/subcommand before the flag hid the invocation · EVIDENCE: the first case passes against the old lint | *"measured at 8 of 39 … `/tasks move <ids> --to`"* → TASK-108:39, `AGENTS.md:279`; *"added by the same epic that wrote this suite"* → git. One-line pointer `(TASK-108)` |
| `:153-156` second flag | pins: `grep -o` stopped at the first flag · EVIDENCE · fixture: the first flag must be declared or the old lint never reaches the second | the three sentences retold as a story tighten to the same three parts; no content leaves |
| `:165-169` prose | pins: prose must not read as an invocation, and why a false positive is worse here · EVIDENCE: errors against a bare-word `ARG_RE` · fixture: unbackticked, several lowercase words | *"a first version wrapped the invocation in backticks"* → git; the **reason** (backticks make the argument repetition unreachable) stays as fixture rationale |
| `:178-182` coverage pins | PIN: neither fails against the previous lint · what each guards (templates ship to consumers; `*.md` would drop two `README.md.tmpl`) | *"because a rewrite of check 4 nearly removed both"* → git |

**Steps**
1. Edit the four blocks in one pass.
2. `skills-lint.sh` + `skills-lint-test.sh` — both pass, 56 cases, every changed line a comment.
3. `AGENTS.md` § Comments table: re-measure **all six** rows with the recorded command (a single-row update
   would make the "re-measured" date line false for the other five), set `skills-lint-test.sh`'s verdict
   to what is actually true — passes except the sites filed on TASK-163 — and bump the date line.
   **`skills-lint.sh`'s verdict changes too, from "passes" to open findings, deliberately:** TASK-162
   verified five findings in it, so the row was already false, and a re-dated "re-measured" line would
   vouch for a verdict known to be wrong. Only the verdict moves to pointers; judging that file stays
   with TASK-163 / TASK-081 / TASK-141.
4. Human test plan: `/review-comments` on the file, then the read-in-sequence check.

**Close gate (2026-09-24), axes side by side:** standards ✅ (⚠ `AGENTS.md:414` restated detail → trimmed
to pointers) · fidelity ✅ C1-C5; four-block widening judged defensible (⚠ the `skills-lint.sh` verdict
change had no recorded reason → recorded in plan step 3) · correctness ✅ no executable line changed, all
six table rows re-measured and match, lint check 5 agrees · comments ✅ run as the human test plan's
`/review-comments` sweep, one in-block finding fixed. Security: not applicable, comments and prose only.
