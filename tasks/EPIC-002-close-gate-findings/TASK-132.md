---
id: TASK-132
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] `skills/populate-tests/SKILL.md` § *The cold drill* is consulted **first** on whether a drill is
      warranted here at all — a negative answer, recorded with its reason, closes this task legitimately
- [ ] If warranted: two runners, each given a **guide-free** working directory and a brief that
      withholds the expected answer — one exercising `/specs init` on a repo with **no** `.map.yml`, one
      exercising the `new-project` seed path on a **non-.NET, non-JS** stack
- [ ] ⚠ The fixture is **not this repo** — `AGENTS.md` § Testing's rule that a change justified by
      naming a repo cannot be drilled on it, and the Python case is the one the finding names
- [ ] Each drill record **names how its runner was obtained** — command, working directory, and the
      result of the coldness check — per `AGENTS.md` § Testing and `populate-tests` § *Acquiring a cold
      runner*. Recording only the brief is what made TASK-079's first two readers unclassifiable
- [ ] The measured question is answered in one line per runner: **did anything unchosen reach the
      rendered `.map.yml`** — a live `ignore:` list the runner did not derive, or an `areas:` entry
- [ ] Findings, if any, go through `/tasks intake --epic EPIC-002` rather than being fixed in place

## Out of scope

- Re-opening TASK-126's template change — its render evidence stands; this tests the **prose**.
- The mechanical guard TASK-126 decided against. If a drill finding reopens that trade-off, it is a new
  task with the new evidence attached, not a reversal argued here.
- `mode:` and the four unanswered ask-steps — [[TASK-127]] owns those.

## Human test plan

- [ ] The drill **is** the test; its record on this task is the deliverable.

## Implementation plan

_Populated by `/tasks plan TASK-132` — leave empty until then._
