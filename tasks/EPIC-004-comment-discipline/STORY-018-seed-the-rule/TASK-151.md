---
id: TASK-151
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: []
findings: [DRILL-142-1]
pr: null
github-issue: null
jira-key: null
---

# The `AGENTS.md` comment measurement was under-evidenced, and this repo has real findings

## Context

Found by `review-comments` on its first real run — `--all` over this repository, as TASK-142's drill.
The skill was pointed at the repo that wrote it and found four comment findings inside
`skills-lint.sh`, a file `AGENTS.md` § Comments explicitly blesses.

**The measurement is not wrong about what it measured; it measured the wrong thing.** Its argument is
framed around line count — *"`skills-lint.sh` looks like a flagrant violation by line count while being
compliant by the test"* — and on that axis it holds: **not one of the ten findings is a length
finding.** What TASK-141 did was count lines and read the two largest blocks for *rationale*. What it
never did was the test's actual question: **search whether the content lives somewhere else.** The
skill ran that search and it does.

**The findings, as reported.** One is excluded: `skills-lint.sh:228-229`'s wrong-check comment is
already TASK-081's, and the skill said so rather than re-filing it.

| Site | Destination | Note |
|---|---|---|
| `skills-lint.sh:4-7` | the code itself | The header enumerates the checks, and **is already wrong** — it lists 1, 2, 3, 5 and omits checks 4 and 6, so a reader counting it finds four checks in a script that runs six. A restated list that went stale exactly as this repo's own rule predicts |
| `skills-lint.sh:107-111` | version history | A superseded measurement kept as a record of the comment's own revision. **Not called 🛑, correctly** — TASK-108:179-180 records deliberately keeping it, so the ⚠ exists to make that decision visible rather than to overturn it |
| `skills-lint.sh:123-128` | the ticket | The 8-of-39 measurement is a **third** copy — TASK-108 carries it at `:39`, `:114` and `:172`, and `AGENTS.md:279` carries it again. Keep the design reasoning at `:130-139` (that lives nowhere else); reduce the measurement to a pointer |
| `skills-lint-test.sh:50` + one more | version history / the code | The renumbering TASK-146 caused, contradicted 23 lines later in its own file |

**The ripple nobody has finished.** TASK-146 inserted a new check 5 and renumbered install-roots to 6.
That renumber has now been chased through `AGENTS.md` twice (once at TASK-142's start) and it is still
moving: **TASK-081's own acceptance criteria cite `skills-lint.sh:159` and call the enclosing block
"check 5"** — both now one renumbering behind. A task whose criteria describe a line that moved is a
task that will be closed against the wrong site.

## Acceptance criteria

- [ ] Each finding above is acted on or dismissed **with a reason recorded** — "left as is" alone does not close this.
- [ ] `skills-lint.sh`'s header stops enumerating the checks, or the enumeration is made complete and something keeps it that way. Do not simply add the two missing rows: that restores a list that will go stale again on the next check added.
- [ ] TASK-081's acceptance criteria are repointed at the current line and check number, or TASK-081 is closed/cancelled if TASK-146 already resolved it.
- [ ] `AGENTS.md` § Comments' measurement table is **re-run against the real test** — for each block, does its content live elsewhere? — and the table says which question it answered. Its own note already says a changed rule invalidates it; a changed *method* does too.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `skills-lint.sh:228-229` — already TASK-081's.
- The comment rule's wording — settled, FEATURE-002 D1/D2.
- `review-comments` itself — TASK-142; this task is what its first run found.

## Human test plan

- [ ] Re-run `/review-comments --all` on this repo after the fixes. Expected: the acted-on findings are gone, and every dismissed one is absent *because the comment changed*, not because the check stopped looking.
- [ ] Confirm the four survivors it named are still left alone — `skills-lint.sh:130-139`, `:262-266`, `:45-46`, `:16-18`. A "fix" that silences the report by making the check less discriminating is the failure mode here, and these four are how it would show.
