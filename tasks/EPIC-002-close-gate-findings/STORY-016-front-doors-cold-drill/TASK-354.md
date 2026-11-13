---
id: TASK-354
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-065-4, DRILL-065-5, DRILL-065-6]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A full `adopt-project` run writes three things the skill does not say it may write

## Context

Spawned 2026-11-13 from TASK-065's full-pass drill (`%LOCALAPPDATA%/Temp/d065b/full`, brief and report kept there).
One cold runner ran a full `/adopt-project` on an adopted fixture with nobody to answer. It raised these
readings; none of them is about scoped runs, and all three predate TASK-065. They are grouped because each is a
write in a full run whose permission or timing the text leaves open.

- **DRILL-065-4 — guide sections written without consent.** `skills/adopt-project/SKILL.md` says "nothing is
  written unasked", and the report's **amended** bucket is "changed with the user's consent". But the agent-guide row
  in `skills/new-project/LAYER.md` reads as an instruction: "**Merge by section.** Add missing `##` sections". With
  nobody present, the runner appended `## How we work`, `## Architecture` and `## Commands` to `CLAUDE.md` unasked and
  reported them as amended.
- **DRILL-065-5 — `## Commands` is stale on arrival.** The guide's sections are rendered before
  `populate-tests adopt` wires a harness in the same run. So `## Commands` read "None found" while the run went on to
  write `pytest.ini` and a `python -m pytest` command. Nothing says which order these steps run in, or that a section
  rendered earlier is refreshed afterwards.
- **DRILL-065-6 — `populate-tests adopt` adds `.gitignore` lines that adoption only offers.**
  `skills/populate-tests/REFERENCE.md` § harness invariants says "add the runner's output dirs … to `.gitignore`".
  Under adoption, `.gitignore` lines are an *offer* (step 3, and the never-write-unasked rule above). The runner held
  back and did not add `.pytest_cache/`, reasoning from the adopter's rule. Neither file says which rule wins.

## Acceptance criteria

- [x] Whether adoption appends missing guide sections unasked or offers them is stated in one place. The agent-guide
      row and the "nothing is written unasked" sentence agree with it
- [x] Either a guide section is rendered after the steps that create what it describes, or the run refreshes it.
      `## Commands` is the measured case
- [x] Whether `populate-tests adopt`'s `.gitignore` lines are written or offered inside an adoption is stated, on the
      side that owns the rule, and the other side points at it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where fill offers and delegated questions are asked: TASK-102
- An absent `workspace:` under `single-branch`: TASK-353 (DRILL-065-2)

## Human test plan

- [x] Re-run the full-pass brief (`%LOCALAPPDATA%/Temp/d065b/full/brief.txt`, on a fresh copy of `d065/adopted` and of
      `skills/`) with a cold runner. Expected: none of DRILL-065-4 … 6 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d354`: a fresh copy of `d065/adopted`, `skills/` at this fix, and the
    d065b full brief unchanged. The runner command was d065b/full's.
    - **Coldness:** no skills listed and no Skill tool.
    - **Writes:** the run created the layer files and amended `tasks/`. It left `CLAUDE.md` and `.gitignore` untouched
      and committed nothing.
    - **065-4:** the guide-section offer was put in step 2's round, itemised and subset-acceptable, and with no answer
      the report reads `CLAUDE.md — … each: offered, unanswered`.
    - **065-5:** the offer itself said `## Commands` "would be rendered last, from what the repo holds by then".
    - **065-6:** "/populate-tests adopt … handed back `.pytest_cache/` as a `.gitignore` line to offer, not write". It
      joined the `.gitignore` offer.
    - **None of 065-4 … 6 is among its undecided points.**
    - **Its points 1–3 and 9** are about where offers go and whether creating rows ask, which is TASK-102's open
      question. Its five-question round limit was new, and is added there.
    - **Recorded here, not filed:** points 4–8 and 10–13 (architecture.md's state, how `docs/features/` is created,
      which commented template fields count, timestamp-only regeneration, the `.env.example` negation, where empty
      Conventions subsections are recorded, deployment evidence, the completeness verdict with rows still open, and
      the Python test glob).

## Implementation plan

Drafted 2026-11-13 by `/fix-next`, as `/tasks plan --no-grill` would write it (triggers: three files, four criteria).

| Reading | Answer | Where |
|---|---|---|
| 065-4 | adding a missing section amends a file the repo owns, so it is **offered**: one itemised offer naming each section, a subset acceptable. With no answer nothing is appended, and the report lists the sections as offered and unanswered | `LAYER.md` agent-guide row (the one place), with `adopt-project` step 3 pointing at it |
| 065-5 | `## Commands` is rendered **after** the fills it reads, the test harness and the CI stub. Ordering says so | `LAYER.md` § *Ordering* |
| 065-6 | a verb chained by adoption writes nothing into another file the repo owns. Its `.gitignore` lines come back as an offer, reported with the `.gitignore` row | `adopt-project` step 3 (owns the adoption's write rule); `populate-tests` `REFERENCE.md` points at it |

**Where the offers are put is TASK-102's open question, and this task does not settle it.** 065-4 says "offered" and
names the shape. It places the offer in step 2's round only because the guide's missing sections are known from step
1, which is the case TASK-102 calls foreseeable and its own analysis already favours.

## Outcome

**The fix.** A full `/adopt-project` run no longer writes into files the user owns without asking.
- **Missing guide sections:** they are offered in step 2's round, itemised with a subset acceptable, and with no
  answer nothing is appended.
- **`## Commands`:** it is rendered after every fill, so it describes the harness and CI the same run creates, not
  *None found*.
- **Chained verbs:** a verb adoption chains writes nothing into another file the repo owns. `populate-tests adopt`'s
  `.gitignore` lines come back as an offer and join the `.gitignore` row's offer.

**Step-6 split.**
- **Text assertions:** 4 of 4 fail on `HEAD`'s copies and pass on the fix, all fix-dependent: the offer, `## Commands`
  last, the chained-verb rule, and populate-tests' offer. The script is `task354-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the d065b full runner appended three sections unasked, rendered `## Commands` as *None found*
    before writing `pytest.ini`, and had to reason out whether to write `.pytest_cache/`.
  - **After:** the d354 runner left `CLAUDE.md` untouched with each section offered, said `## Commands` renders last,
    and took `.pytest_cache/` back as an offer.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **Offer, not append.** Appending fills a gap the survey found, but it is still an amendment to the user's own file.
  The skill's opening promise ("nothing is written unasked") and the report's `amended` definition ("with the user's
  consent") already decided this; the guide row was the one place contradicting them.
- **The offer's place is step 2's round, and only this offer's.** Step 1 knows which sections are missing, which is
  the foreseeable case TASK-102's own analysis favours. Where the other fill offers go is still TASK-102's, and this
  task left them alone.
- **`## Commands` is ordered last, not refreshed afterwards.** LAYER's Ordering already prefers ordering to step 3c's
  re-run as "the cheaper guarantee".
- **The rule for chained verbs lives in `adopt-project`**, which owns adoption's consent. `populate-tests` points at
  it, so a direct `/populate-tests adopt` keeps writing its `.gitignore` lines: there the user asked for the harness.
- **Spec stamps.** `project-baseline` is restamped to `b5b3520`. `test-authoring` got its one sentence, but its stamp
  stays at `222c36d`: TASK-271 and TASK-283 changed `populate-tests` since then without a regen, so a new stamp would
  claim a currency nobody checked.

**Close gate (inline, about 20 lines of prose over three files):**
- **Standards:** layer parity holds. The offer and the ordering are in LAYER.md, the one inventory. `new-project`
  writes its guide whole from the seed, so it gains no offer, and its `## Commands` source is already step 5's
  skeleton.
- **Intent:** criteria 1–4 met.
- **Correctness:** none found.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.**
- **The `test-authoring` spec is behind its sources** by two commits (TASK-271, TASK-283). A `/specs regen
  test-authoring` would bring it current. Not run here: outside this task.
- **The one-runner readings** listed under the Human test plan.

Filed 2026-11-13, after comparing all six adoption drills: the readings here that a second runner also raised are TASK-356 (`architecture.md`, empty Conventions subsections, the Dockerfile row) and TASK-357 (timestamp-only regeneration, template fields, `docs/features/`, empty renders, the negation). The stale spec is TASK-359.

## Progress log

- step 2 — picked; ranked above TASK-099 and TASK-102 (same story, correctness-invariants, key 6 inert) because each of its three readings is a write a full adoption makes without stated permission or at the wrong time (key 1, wrong results in a user's repo), while TASK-099 and TASK-102 are readings about what a survey reports or when it asks (key 4: each asks for a rule to be designed)
- step 3 — verified: held. LAYER's guide row reads "Add missing `##` sections" as an instruction against "nothing is written unasked"; Ordering puts the guide first, before the harness and CI that `## Commands` reads; populate-tests REFERENCE says "add … to `.gitignore`" with no adoption exception
- step 3b — planned: drafted inline as /tasks plan --no-grill (three files, four criteria)
- step 4 — layer: local
- step 5 — fix in skills/new-project/LAYER.md (agent-guide row: sections offered, no-answer outcome; § Ordering: `## Commands` last), skills/adopt-project/SKILL.md step 3 (chained verbs write no other owned file; guide-section pointer), skills/populate-tests/REFERENCE.md (`.gitignore` lines offered when chained from adoption); assertions in scratchpad task354-check.sh
- step 6 — reverted fix (HEAD copies): 4/4 assertions failed; fix-dependent = E1 offer, E2 Commands last, E3 chained-verb rule, E4 populate-tests offer; contract pins = skills-lint. Behaviour: d065b/full raised 065-4/5/6 on the old text; full-pass re-drill on fixed text running (d354)
- step 7 — respecced project-baseline (Gaps are filled in dependency order…) and test-authoring (harness invariants: `.gitignore` offered under adoption), surgical, both restamped; intended — TASK-354 criteria 1–3
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
