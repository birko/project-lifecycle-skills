---
id: TASK-263
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: [TASK-078]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`'s candidate key is unstable, and most rejections can never be re-checked

## Context

Found while doing **TASK-077**, by its cold drill (2026-10-06, a `ClientApi.CSharp` clone) and its correctness
review. These are defects in the scan and the gate (Steps 1, 4 and 5 of `skills/improve-architecture/SKILL.md`),
which TASK-076 built. TASK-077 owns only the report, so they are filed here rather than widening it.

- **The key is unstable across runs.** A key is `<n>:<path>`. The drill had two candidates on one main file and
  class, which collided, and it improvised a member suffix. A suffix added only "when two share a file" depends on
  what one run happened to find. Run A files `2:src/Client.cs`; run B finds two members in that file, keys them
  `#OnError` and `#Send`, and Step 1 matches neither to A's task. So no `recurs after`, no `already filed`, and a
  duplicate is filed.
- **Rejections carry no key.** The dropped-entry line (stated on both sides: `intake.md` step 3 and this skill's
  Step 5) begins with a bare `<path>`. Two rejected members of one file, or two classes, collide in the durable
  record, and Step 5's re-check keys on the path alone. The same holds for "Previously rejected".
- **Only deletion-test rejections are re-checked.** Step 5's re-check covers "each deletion-test rejection", and an
  item-4 rejection by implication. A rejection from classes 1, 3, 4 or 5 (the drill hit one: a co-change pair whose
  cause a later rewrite removed) is recorded but never re-checked. Its `callers:` slot is undefined, so the next
  run either raises it again or suppresses it forever.
- **Classes 1 and 4 have no rejection path** for a signal that fails on a closer look. The drill had to invent one.

## Acceptance criteria

- [x] The key is stable across runs: `#<member>` is part of it whenever the candidate concerns one member rather than the whole file, never only when another candidate shares the file
- [x] Every rejection entry begins with the candidate's key, in this skill's Step 5 and in `skills/tasks/verbs/intake.md` step 3 alike (both sides of the contract change together), and "Previously rejected" carries the key too
- [x] Every rejection except `held by ADR` is re-checked by Step 5, and the `callers:` slot is defined for each gate: the paths the verdict turned on (callers, implementations, co-change partners, the callers of the function or interface)
- [x] Classes 1, 3, 4 and 5 have a rejection path for a signal that does not hold on a closer look
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The report's shape (TASK-077) and the intake handoff that writes the key onto filed tasks (TASK-078)
- Deferred to TASK-265 — rung 2 does not say whether candidates outside the hot spots are raised (found by this task's two runs)

## Human test plan

- [x] Run the pass twice on the same scratch clone (a cold runner, as in TASK-076 and TASK-077), with the first run's rejections pasted in as an earlier intake epic's dropped list. Confirm the second run reports every unchanged rejection as `previously rejected, unchanged`, including one from a class other than 2. Then change one rejected file and confirm only that one is re-tested

## Implementation plan

Drafted 2026-10-06 by the `Plan` agent; checked against both files.

1. **The key:** `<n>:<path>`, or `<n>:<path>#<member>` whenever the candidate concerns one member (a method, event, property, injected dependency or nested type, named by its identifier as written, so overloads are one). It depends on the candidate alone, never on what else the run found. Two whole-file candidates of one class on one file are one candidate. **Renames are a stated limit,** as they are for paths in Step 2. To parse it back: the class runs to the first `:`, the path to the last `#` (or the end), and the key ends at an entry's first ` — `.
2. **Entries lead with the key, on both sides:** `- <key> — <reason> (callers: <paths>; at <commit>)` and `- <key> — held by ADR NNNN — <title> (at <commit>)`. `<reason>` starts with the gate that killed the candidate (`deletion test:`, `item 4:`, `signal fails:`), so a re-check knows which set to rebuild. EPIC-007's table stays valid. No migration: no `- <path> —` entry exists anywhere yet.
3. **The `callers:` slot reuses Step 4's two sets:**
   - callers, for the deletion test and for classes 3 and 5;
   - co-change partners, for classes 1 and 4 (a class 4 raised on reading internals takes its callers);
   - implementations, for item 4;
   - `none` when there are none.

   The label stays `callers:` for contract stability.
4. **The re-check covers every rejection except `held by ADR`:**
   1. If the key's path is gone from `git ls-files`, report `rejected file gone` and drop it.
   2. Otherwise run `git log <commit>..HEAD` over the path and the slot.
   3. Rebuild the set the gate names and compare it with the slot.

   On any change, re-run that gate. A member that is gone is reported as `rejected member gone`. The report gains a **Rejections gone** section: this touches TASK-077's report, and is the narrowest edit criterion 3 forces.
5. **"Signal fails":** `Gate: signal fails — <class> — <evidence>`, only on a named commit or path, never on judgement alone.
6. **Every print site follows:** Step 1 matching by key, Step 5, Step 6's held form, the part table, the page sections and stdout. In intake, the `IA-*` row, the "judged against" row, the slot sentence pointing at the pass, and the held form.
7. A note on TASK-078: its `<class>:<path>` is now `<key>`.

**Human test plan:** two cold runs on a remote-less clone of `%TEMP%/d077`. Between them, commit a fake earlier-run intake epic holding run 1's Rejected section verbatim, edit one rejected file, and remove another. Run 2 should report the rest as unchanged with byte-identical keys, including one rejection outside class 2; re-test only the edited one; and list the removed one under "Rejections gone".

## Progress log

- 2026-10-06 — Picked; plan drafted by the `Plan` agent and checked. Edited both sides of the contract: `skills/improve-architecture/SKILL.md` Steps 1, 4, 5 and 6 and the report, and `skills/tasks/verbs/intake.md` step 3 and its `IA-*` row. Left a note on TASK-078 that its key is now `<key>`. Lint OK.
- 2026-10-06 — **Human test plan: two cold runs** on `%TEMP%/d263`, a remote-less clone of the TASK-077 fixture (with its seeded `docs/adr/0001`).
  - **Runner:** `claude -p --disable-slash-commands --permission-mode acceptEdits --add-dir <%TEMP%/d263outN> --allowedTools "Bash(git:*)" … "Write" < brief`. **Coldness:** both runs listed no skills. Each brief held the procedure and its linked passages, with no direction and no expected answer.
  - **Run 1, at `0eaa1c3`:** member keys came out (`2:…CommonAbstractClient.cs#OnErrorResponseContent` as a candidate; `#HttpClientHandlerFactory`, `#OnRequest` and `#OnResponse` as rejections). 10 rejections, all key-led and gate-led, six of them class 4 `signal fails` entries naming their commits.
  - **Between the runs, in the clone only:**
    - a committed fake intake epic, `kind: review-intake`, `source: improve-architecture — run 1 …`, holding run 1's Rejected section verbatim;
    - `BaseApiClient.cs` edited;
    - `FinStatApi/FinStatApi.csproj` removed.

    Neither path appears in any other entry.
  - **Run 2, at `a4bf447`:**
    - **Unchanged:** 4 rejections reported `previously rejected, unchanged since 0eaa1c3`, with keys byte-identical to run 1, including the class 4 desktop csproj (outside class 2).
    - **Edited:** `BaseApiClient.cs` was re-tested; same verdict, re-recorded at `a4bf447`.
    - **Removed:** `FinStatApi.csproj` is under **Rejections gone**.
  - **Defect it exposed, fixed:** four tester csproj rejections were re-run with no code change, because run 1 had recorded only the co-change pairs it raised each candidate on, while run 2 rebuilt every partner. Step 5 now says the slot records the whole set, built the same way every run.
  - **Spawned:** TASK-265. Run 1 raised a class 1 candidate outside the hot spots and run 2 did not; the readers took "examined first" differently, and so did TASK-077's.
- 2026-10-06 — **Close gate (step 5b), each axis reported separately:**
  - **Standards** ([[verify-conventions]]): no blockers. Two warnings, both fixed (they overlap correctness #3 and #6): a class 4 rejection did not say which set its slot held, and the member-gone check sat after the numbered steps. A note fixed too: "drop it" now says the earlier run's record is never edited here, and a matching note goes on TASK-078.
  - **Fidelity** ([[verify-intent]]): all 5 criteria built. Its scope notes (the Rejections gone section, the whole-set rule, the `IA-*` wording, the TASK-078 note, TASK-265) are planned or drill-driven. Its flagged prefix mismatch is correctness #1.
  - **Correctness** (code-review pass): 7 findings, all fixed:
    1. `<reason>` is now the gate line verbatim, so the prefix cannot drift from it;
    2. a co-change slot is not rebuilt (a new partner needs a commit to the key's path, which `git log` sees; a pair ageing out of the window is not a code change), and the trace's files are evidence, not the slot;
    3. a class 4 gate line names its signal (`4, co-change` or `4, internals`);
    4. a `#` counts as the member separator only when an identifier follows it (no `/`, no `.`), so `F#/Parser.fs` parses;
    5. the paths are separated by `, ` on both sides;
    6. the member-gone check is now step 2, before the log;
    7. an incomplete set ends with `, incomplete`, on both sides.
  - **Security:** not applicable, because the diff is prose with no security surface. **Comments:** not applicable, because there are no code comments in range.
  - **Out of scope (5d):** 2 boundaries (TASK-077, TASK-078) and 1 spawned (TASK-265), 0 declined.
