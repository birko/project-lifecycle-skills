---
id: TASK-162
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: [TASK-141]
findings: [DRILL-141-2]
pr: null
github-issue: null
jira-key: null
---

# `skills-lint-test.sh` was never swept, and it holds nine findings

## Context

Found by re-running **TASK-141**'s test plan on 2026-09-20, after its four blockers closed. Two cold
readers, a fixture carrying the whole guide **minus the measurement table only**, and — the change
that mattered — **all six scripts** rather than one.

**Six readers had already swept these scripts and missed all of this**, because every earlier sweep
was scoped to `skills-lint.sh`. TASK-141's measurement claimed six scripts examined; only one ever
was by anyone but me. **That is the finding behind the findings**, and it is why this task exists
rather than a tidy-up.

Everything below was verified against the tree before filing.

### The QA log, and it has already rotted

`skills-lint-test.sh:6` — *"A review of the first version found eight defects; every one has a case
here."*

| Claim | Reality |
|---|---|
| *"the first version"* | `:271` heads **"Regressions from the second review pass"** |
| *"eight defects … every one has a case here"* | the suite runs **56** cases |

Both readers reported it. T caught the rot. A note about a past review that no longer describes the
file it sits in — the QA-log row, decayed exactly as the rule predicts.

### One sentence, four copies — all four verified

*"A negative assertion passes for free if the thing it checks is deleted."*

| Where | Text |
|---|---|
| `skills-lint-test.sh:70` | *"A bare 'must not contain' passes trivially when check 4 is absent"* |
| `skills-lint-test.sh:321-322` | *"Asserting the exit code alone would also pass if the whole check were deleted"* |
| `skills-lint-test.sh:387` | *"passes trivially when the section is deleted"* |
| `AGENTS.md:359-360` | *"a 'must not appear' check passes trivially when the section is deleted"* |

The helper's contract line earns its place; the two call sites should keep only their case-specific
half.

### Three more restatements

| Site | Restates |
|---|---|
| `:4-5` | § Testing — *"It is the repo's only gate, so a silent regression in it disables checking entirely with no signal."* `skills-lint.sh:2` already does this right, as a pointer |
| `:41-42` | a § Testing bullet near-verbatim — **and drops the maintenance rule that bullet carries** (*"Keep the POSIX path first…"*), so the copy is also lossy |
| `:284-286` | what `skills-lint.sh:159-160` already states in pointer form |
| `:50-52` | borderline — *"Check 6 is advisory and never touches the exit code"* is § Testing; the `rc -eq 0` justification beside it earns its place |

### Two comments that name things which do not exist

- `skills-lint-test.sh:322` says **`check_silent`**; the helper is `case_silent` (`:66`).
- `skills-lint-test.sh:70` says **"check 4"**; `case_silent` greps `== 6. install roots`, as `:76`'s
  own failure message says.

Not comment-placement defects — accuracy defects in comments. Filed here because they were found in
the same sweep and fixing them separately means reading the same lines twice.

## Acceptance criteria

- [x] Each of the nine is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [x] The QA log at `:6` goes. The two sentences before it — why a silent regression here disables the gate, and what each case does — are the file's actual contract and stay.
- [x] Of the four copies of the negative-assertion rationale, **the helper keeps its contract line** and the call sites keep only what is specific to their case. Do not delete all four: the rule itself is in `AGENTS.md` and the helper is where it is operative.
- [x] `:41-42`'s fix restores the dropped maintenance rule or points at it. A lossy copy replaced by a lossy pointer is not a fix.
- [x] `check_silent` → `case_silent`, and `:70`'s "check 4" → the check it actually greps.
- [x] Every deletion names the destination that holds the content, **verified by reading it**.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, and the case count is unchanged — a comment fix that changes what runs is a different task.

## Out of scope

- `skills-lint.sh:219`'s wrong check number — **TASK-081**, now confirmed by a sixth independent reader.
- `AGENTS.md`'s own drift (§ *A repo-level check* saying "check 5", § Testing saying 47 cases against 56) — **TASK-081** and **TASK-029** respectively; T flagged both as evidence the numbers rot, not as script defects.
- The `pi-install` header both readers reported — handled directly on **TASK-141**, since it reverses a TASK-148 criterion rather than adding new scope.
- The `ARG_RE` block — **TASK-141** records the evidence that settles it; acting on it belongs with whoever takes that.
- Deferred to **TASK-163** — the comment findings this task's drill surfaced outside the nine (`skills-lint-test.sh:313`, `:320-322`; `skills-lint.sh:118`, `:144-147`, `:167-170`, `:202-203`, `:291-295`).
- **Dismissed, not deferred:** reader B's claim that `m_sentinel` ("stale .lint-fail in the repo") *"can only ever pass"* because the lint now uses `mktemp`. It is a regression pin: a change reintroducing a repo-local failure file without clearing it fails that case. A guard that passes against today's code and fails against the regression it names is working, not dead.

## Human test plan

- [x] Two cold readers on the same six-script fixture. Expected: these nine gone, and `skills-lint.sh`'s existing pointers still cleared rather than newly reported. — **ran 2026-09-24, two rounds; passed on round 2 with one exception, recorded below.**
- [x] Expected failure to watch for: the fix deletes the negative-assertion rationale from **all four** places, leaving the helper with no statement of its own contract. The rule lives in the guide; the helper is where it bites, and those are different jobs. — **did not occur**: the helper keeps *"Require check 6 to have RUN before trusting the absence"*, and reader D passed `:68` by number.

### Drill record

**Runner:** `cd <fixture> && claude -p --disable-slash-commands --permission-mode plan < t162-brief.txt`,
four runs, two per round, each in its own fixture copy under this session's scratchpad (outside any git
repo — `git rev-parse` fails there). **Coldness:** the brief's first line asks the runner to list its
skills; all four answered *none*. **Fixture:** the whole `AGENTS.md` minus lines 403-448 (the measurement
table and its record line — one line wider than TASK-141's 403-447, because the record's second line
would otherwise have survived orphaned), plus all six scripts. Round 2 differed from round 1 only in
`skills-lint-test.sh`.

**Brief, verbatim:**

> First, list every skill or slash command available to you in this session, or say plainly that there are none.
>
> Then: this directory is a repository whose agent guide is AGENTS.md. Apply that guide's § Comments rule to every comment in these six scripts: .github/workflows/skills-lint.sh, .github/workflows/skills-lint-test.sh, install.sh, install.ps1, pi-install.sh, pi-install.ps1.
>
> For each comment the rule says should change, report: file:line, which row or banned instance of the rule it falls under, and the destination where its content already lives — quote the destination text you read, or say you could not find it. Also report any comment that names something which does not exist in the code. If a file has no findings, say so explicitly. Do not edit any file.

**Round 1 (A, B) — the nine gone, four residues in my own edits.** None of the nine was reported. But the
rewrite left four sites that were still wrong, all on lines this task touched, all fixed in-task:

| Site | Residue | Reader | Fix |
|---|---|---|---|
| `:4` | *"asserts the lint's exit code"* — three helpers assert output | A | *"exit code, its output, or both"* |
| `:280` | *"four states"* — check 5 has five branches (`skills-lint.sh:185-197`); **my rewrite carried the wrong number forward** | A | five |
| `:68` | the helper's line still restated § Testing | B | contract kept, reason → pointer |
| `:40` | the mechanism line still restated § Testing | B | one-line pointer |

**Round 2 (C, D) — clean for this task.** Neither reader reported any TASK-162 site; D lists `2-5, 41,
48-50, 68, 279-282, 317-318` among its passes. The `skills-lint.sh:158-160` pointer (TASK-154's) resolved
for both.

**The one exception to "existing pointers still cleared":** `skills-lint.sh:144-147` was reported by A, C
and D — it points at an `AGENTS.md` section for content that section does not hold. Not caused by this
diff (`skills-lint.sh` is untouched here); an older pointer nobody had checked against its destination.
Filed on TASK-163 with the rest of the out-of-nine findings.

## Implementation plan

⚠ Acceptance criteria question: criterion 2 says the two sentences at `:4-5` "stay", while the
context lists `:4-5` as a restatement of § Testing. Resolved by keeping **both facts** and reducing the
rationale to a pointer, in the shape `skills-lint.sh:2` already passes with — the fact that this is
the only gate survives as a clause, the elaboration goes. If "stay" meant verbatim, F5 is dismissed
instead and that line of the plan reverts. **Settled 2026-09-24 by František Bereň at the close gate:
keep the pointer.** Raised by the fidelity pass as the gate's only ⚠.

**Close gate (2026-09-24), four axes side by side:** standards ✅ no findings · fidelity ✅ C1, C3-C7,
⚠ C2 (settled above) · correctness ✅ every changed script line is a comment, 56/56, lint exit 0 ·
comments ✅ no 🛑/⚠ (💡 `:382`'s pointer is two hops to § Testing; left). Security: not applicable, no
security surface in a comment-only diff.

Line numbers are as of `8565dee`; the file has shifted by one since filing (`:41-42` is now `:42-43`).
Case count before: **56** — re-count after, criterion 7.

**The nine, and what each gets** (destination verified by reading it, criterion 6):

| # | Site | Action | Destination that holds the removed content |
|---|---|---|---|
| F1 | `:6` QA log | delete the sentence | git history; the suite's own `printf` section headers name the passes |
| F2 | `:70-72` `case_silent` guard | **keep the contract line**; fix "check 4" → check 6; cut the bitten-once history | § Testing (*"its negative assertions must require the section to have run"*); the history is git |
| F3 | `:321-322` no-pair call site | keep the case-specific half (assert the message, not just the exit); `check_silent` → `case_silent` as a pointer | the helper, F2 |
| F4 | `:386-388` legit-pi call site | keep why `roots/pi is in sync` proves the loop cleared every link; cut the generic clause to a pointer | the helper, F2 |
| F5 | `:4-5` header | fact kept as a clause + `(AGENTS.md § Testing)`; mechanism sentence ("each case builds a fixture…") kept verbatim | § Testing, *"It is the repo's only gate…"* |
| F6 | `:42-43` `mk_link` | keep the one-line mechanism (MSYS copies, so fall back to install.ps1's junction) and **point at § Testing for the order-and-guard rule** the copy dropped | § Testing, *"Keep the POSIX path first… guarded on `cygpath`"* |
| F7 | `:284-286` check-5 header | replace the why-two-copies clause with the pointer `skills-lint.sh:159-160` already uses; keep the four-states sentence (test-specific) | § *Where the same prose must exist in two files*; D13 |
| F8 | `:50-52` check-6 header | borderline → reduce: keep *"`case_is` sees only the exit code"* (the premise of the next sentence) with an advisory pointer; keep the `rc -eq 0` justification | § Testing, *"advisory sections… never change its exit code"* |
| F9 | the two wrong names | folded into F2 (`check 4`) and F3 (`check_silent`) — same lines, one pass | — |

**Steps**
1. Record the before count: `bash .github/workflows/skills-lint-test.sh | tail -1`.
2. Edit F1–F9 in one pass over the file, top to bottom.
3. Re-read each destination named above, in the working tree, and confirm the text is actually there.
4. `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` — both pass, same case count.
5. Watch the stated failure mode: the helper must still state its own contract — deleting all copies is
   the one outcome this task forbids. (Round 1 of the drill then moved the helper's *reason* to a
   pointer too, so the check is now for *"Require check 6 to have RUN"*, not the phrase "passes trivially".)
6. Human test plan: two cold readers, recipe per `skills/populate-tests/SKILL.md` § *Acquiring a cold runner*.

**Risk:** the only behaviour-bearing edit is none — every change is inside `#` lines. Step 4's unchanged
count is the proof.
