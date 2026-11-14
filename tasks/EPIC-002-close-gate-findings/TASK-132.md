---
id: TASK-132
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
picked-by: fix-next
priority: P2
assignee: unassigned
created: 2026-09-17
depends-on: [TASK-126]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Cold-drill the two render instructions TASK-126 wrote, because a faithful renderer is exactly what they address

## Context

Spawned by `/tasks close TASK-126 --unattended` step 5d, from a `/verify-conventions` warning on that
task's own close: the change is a non-trivial skill change to **two verbs' render instructions**, and
its `## Human test plan` was a mechanical faithful-render check rather than a drill.

The render check was the right instrument for the **template** and it passed cleanly — 6 values minted
before the fix, 0 after, both parsing. It cannot test the half that matters most here, which is prose:

- `skills/new-project/SKILL.md:97` — *"**write** globs for the stack you just chose rather than
  uncommenting the examples, which are .NET/JS"*
- `skills/specs/verbs/init.md` step 6 — *"on the render branch, `areas:` and `ignore:` are values this
  run supplies, not lines it copies"*

**The failure mode these two sentences address is a correct reader following them.** That is the exact
shape a cold drill exists to measure and the exact shape an author cannot measure on their own prose —
DRILL-109's B2 runner carried five `ignore:` globs into a Python fixture and *explained itself
correctly* (*"I kept them because step 6 says to render the template"*). The fix changed what step 6
says; nothing has yet checked what a cold reader does with the new wording.

`AGENTS.md` § Testing states the standing rule this is owed under: *"The lint is the floor, not the
ceiling … Every non-trivial skill change carries that drill as its `## Human test plan`."*

## Acceptance criteria

- [x] `skills/populate-tests/SKILL.md` § *The cold drill* is consulted **first** on whether a drill is
      warranted here at all — a negative answer, recorded with its reason, closes this task legitimately
- [x] If warranted: two runners, each given a **guide-free** working directory and a brief that
      withholds the expected answer — one exercising `/specs init` on a repo with **no** `.map.yml`, one
      exercising the `new-project` seed path on a **non-.NET, non-JS** stack
- [x] ⚠ The fixture is **not this repo** — `AGENTS.md` § Testing's rule that a change justified by
      naming a repo cannot be drilled on it, and the Python case is the one the finding names
- [x] Each drill record **names how its runner was obtained** — command, working directory, and the
      result of the coldness check — per `AGENTS.md` § Testing and `populate-tests` § *Acquiring a cold
      runner*. Recording only the brief is what made TASK-079's first two readers unclassifiable
- [x] The measured question is answered in one line per runner: **did anything unchosen reach the
      rendered `.map.yml`** — a live `ignore:` list the runner did not derive, or an `areas:` entry
- [x] Findings, if any, go through `/tasks intake --epic EPIC-002` rather than being fixed in place

## Out of scope

- Re-opening TASK-126's template change — its render evidence stands; this tests the **prose**.
- The mechanical guard TASK-126 decided against. If a drill finding reopens that trade-off, it is a new
  task with the new evidence attached, not a reversal argued here.
- `mode:` and the four unanswered ask-steps — [[TASK-127]] owns those.

## Human test plan

- [x] The drill **is** the test; its record on this task is the deliverable.
  - **Passed 2026-11-14.** Warranted per `populate-tests` § *When it is warranted*: both sentences rewrite a rule a
    reader must apply, and getting it wrong is silent (a plausible `ignore:` list in the wrong stack). Three cold
    drills, each run with `claude -p --disable-slash-commands --permission-mode acceptEdits` from a fixture folder
    under `%LOCALAPPDATA%/Temp` holding a `skill/` copy and no guide; each runner listed no skills.

    | Drill | Path | Fixture | Anything unchosen in `.map.yml`? |
    |---|---|---|---|
    | d089a | `/specs init`, no map | a deployed service whose behaviour is an uninitialised submodule | **No**: `ignore:` = 4 paths it classified, `areas: []`, examples still commented |
    | d089b | `/specs init`, no map | a Tcl tool with `.trf` rule files | **No**: one derived area, `ignore: README.md`, examples still commented |
    | d132 | `new-project` seed | a Python 3.12 CLI (`pyproject.toml`, pytest), empty folder | **No**: seven Python globs it wrote for the stack it set up (`__pycache__`, `.venv`, `build`, `dist`, `*.egg-info`, `tests`, `uv.lock`), `areas: []`, `coverage: unverified`, examples still commented |

    d089a and d089b were run for TASK-089 the same day, through the same cold-runner channel; their maps are re-read
    here for this task's question.

## Implementation plan

Inline: check whether today's drills already answer the `/specs init` half, then drill the `new-project` seed path on a Python stack.

## Outcome

**Both render instructions hold under cold readers.** No runner carried the template's .NET/JS globs into a non-.NET,
non-JS map, and no `areas:` entry appeared that the run did not derive. TASK-126's prose is confirmed; nothing changes.

**Findings.** None meets the bar for `/tasks intake`. d132's point 7 (seed hint comments above their tokens) is a
third runner on TASK-370's DRILL-067-1, recorded there. Its other points come from one runner and are recorded here:
the scaffold's task-mode question has no answer-less path of its own (it borrowed `tasks init`'s); whether a CLI is a
UI kind for the Output/UX question; whether `populate-tests adopt` treats a just-made `tests/` as an existing
harness; and that nothing re-renders the dashboards after the skeleton exists, so DV10 cannot fire at birth.

**Close gate (inline):** no skill text changed. Standards and intent: all six criteria met. CI: nothing new to test.

## Progress log

- step 2 — picked; the next P2 non-decision task in the pool (TASK-268 and 269 are wide architecture work, TASK-059 waits on TASK-024)
- step 3 — verified the /specs init half is already answered by today's cold drills d089a and d089b (no `.map.yml`, Tcl and a compose/submodule repo): every live `ignore:` and `areas:` entry in both maps was derived from the fixture, and the .NET/JS examples stayed commented. The new-project half (a non-.NET, non-JS stack) has no drill yet
- step 6 — behavioural: d132 (Python scaffold) plus d089a and d089b re-read; nothing unchosen in any map
- step 7 — no respec: no skill text changed
- step 8 — closed inline; commit in git log
