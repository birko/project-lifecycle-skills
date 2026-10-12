---
id: TASK-283
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
picked-by: fix-next
created: 2026-10-07
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-272-1]
pr: null
github-issue: null
jira-key: null
---

# `/populate-tests verify` and `ledger` never say what they do when there is no harness

## Context

Spawned from TASK-272's correctness review (2026-10-07). TASK-272 made `survey` read-only in every case and named
`populate` as the only mode that chains `adopt` (`skills/populate-tests/SKILL.md`, the adopt and survey bullets).
`verify` and `ledger` say nothing about a repo with no harness, and they never did. Now that one mode is named
as falling back to `adopt`, a reader can take the silence either way: that `verify` scaffolds a harness too, or
that it runs nothing and reports success.

## Acceptance criteria

- [x] `verify` states what it does with no harness found (using the test REFERENCE.md § Adopt uses), and never reports a pass over a suite that does not exist
- [x] `ledger` states the same
- [x] `docs/specs/test-authoring.md` is regenerated for the change
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `survey` and `populate` (TASK-272)

## Human test plan

- [x] From a cold runner, run `/populate-tests verify` in a scratch repo with no harness, and confirm the files it writes and the result it reports match what the skill now says
      **Passed 2026-10-12.** Command: `claude -p --disable-slash-commands --allowedTools "Bash,Read,Write,Edit,Glob,Grep" < brief.txt`, run inside the fixture, with the skill text inline. Fixture: a git-initialised Node library (`package.json` with npm's placeholder `test` script, `src/index.js`, `README.md`), with no test directory, no runner config and no `CLAUDE.md`. Coldness check: **not answered**. The runner left out the `SKILLS-SEEN:` line it was asked for, so it is not confirmed cold, though the channel is the recipe that answered `none` on every earlier drill. Result: `git status` was clean afterwards, so nothing was written; it ran nothing, reported no pass and no count, and ended with `no harness — nothing verified; run /populate-tests adopt, then populate`. That matches the skill.

## Implementation plan

_Populated by `/tasks plan TASK-283` — leave empty until then._

## Outcome

**What changed.** `/populate-tests verify` and `ledger` said nothing about a project with no test harness. Only
`populate` was named as wiring one, so a reader could take the silence either way: that `verify` sets up a
harness too, or that it runs nothing and reports success. Now:
- `verify`, with no harness, runs nothing, writes nothing and never calls `adopt`. It ends with `no harness —
  nothing verified; …`. With a harness but no test in the scope, it ends with `no tests in <scope> — nothing
  verified`. Neither reports a pass, a count or `0 failed`.
- `ledger` moves an item to `[auto]` only when the spec it names exists. With no harness, it writes every item
  as `[manual]` and ends with the same no-harness line.
- The `adopt` bullet now names `survey`, `verify` and `ledger` as the modes that never call it.
- Respecced `test-authoring`: the modes requirement and the ledger requirement.

**Step-6 split.** The task's own test plan, run twice in identical scratch fixtures, with the skill text from
`HEAD` (before the fix) and from the working tree (after it). **Neither runner wrote a file or reported a pass,
so the outcome did not split.** The difference is what each runner had to decide alone:
- **Before:** the runner executed the placeholder `npm test` (exit 1) and then had to reason that this was
  neither green nor red.
- **After:** the runner ran nothing and ended with the stated line.

So the fix-dependent evidence is the executed placeholder and the reasoning it forced, not a false green. This
runner avoided the false green by its own judgement, which the old text did not require of it. Neither runner
answered the coldness check (above). The lint passes either way, so it is a contract pin, not evidence.

**Judgement calls.**
- **`verify` never wires a harness.** A harness wired by `verify` holds no test, so the run would report over
  an empty suite, which is the false green this task exists to prevent. The stricter alternative, refusing
  outright with an error, was rejected because the run's report is the useful output: it names the next two
  commands.
- **Pulled in "harness, but no test in the scope".** It has the same root cause, a run over nothing reported as
  a result, and it sits in the same bullet.
- **`ledger` still writes, with everything `[manual]`.** Its job is the checklist, and with no automated test
  every item is honestly manual. Writing nothing would hide the surfaces.

**Flagged, not fixed.** Nothing. Out of scope (`survey`, `populate`) is a boundary owned by TASK-272.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. Each no-harness outcome is a reported state, not a value that reads as decided. No ask-step
  was added. No new cross-cutting pattern.
- *Fidelity*: pass. Criteria 1 and 2 are the `verify` and `ledger` bullets, criterion 3 is the respec, and
  criterion 4 is lint OK. `survey` and `populate` were left untouched.
- *Correctness*: one finding, fixed before commit. The `adopt` bullet still said only `survey` never calls it.
- *Security* and *Comments*: not applicable.

## Progress log

- step 2 — picked; ranked above TASK-299 because a verify run with no harness can report a pass over a suite that does not exist, a false green from a verification step reachable on any repo without tests (keys 1-3), while TASK-299 changes a priority silently only on hybrid Jira projects (key 2). Key 6 not needed: both correctness-invariants; key 7 (P3 here) is below both
- step 3 — verified: held. The verify and ledger bullets in skills/populate-tests/SKILL.md say nothing about a missing harness, while survey reports it and populate chains adopt. Pulled in, same root cause: a harness with no test in the requested scope, where verify would equally run nothing and could report it as a pass
- step 4 — layer: local
- step 5 — fix in skills/populate-tests/SKILL.md (verify and ledger no-harness outcomes; adopt bullet); evidence is a drill, not a test file (prose)
- step 6 — reverted fix (HEAD text, identical fixture, cold runner): no write and no pass either way; before = ran the placeholder npm test and reasoned about its exit 1, after = ran nothing and ended with the stated line; fix-dependent = that pair; contract pins = skills-lint.sh; coldness line not answered by either runner
- step 7 — respecced test-authoring; requirements changed: the modes requirement (verify and ledger no-harness outcomes), the manual-ledger requirement ([auto] only when the spec exists)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
