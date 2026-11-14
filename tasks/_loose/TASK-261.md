---
id: TASK-261
parent: null
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [IA-3, IA-4]
pr: null
github-issue: null
jira-key: null
---

# Run the deletion test on the three `help` verb files, and keep or fold each one

## Context

Found while doing **TASK-075**. Its human test plan said to run the new deletion test (`skills/tdd/deep-modules.md`
§ *The deletion test*) on a small module in this repo's `skills/` tree.

- **`skills/tasks/verbs/help.md`** (11 lines, one caller: the router) **concentrates**. The `tasks` router already
  says, at `skills/tasks/SKILL.md:35`, "If user types `/tasks help` → print the verb table above and exit". Inlined,
  the file collapses into that line, and the only thing left over is its one-line hint, "Bare `/tasks` shows the
  status snapshot."
- **`skills/specs/verbs/help.md` and `skills/feature/verbs/help.md`** follow the same pattern, but they are **not
  checked yet**. `specs`' file carries its own menu text rather than repeating the router's table, so it may
  **merely move**. Check each one separately.

**Why this is a trade-off and not a plain deletion:** AGENTS.md § *Naming* says "verb files are named for the
verb", and every router row points at a file. Folding a verb into its router breaks "one file per verb" for the one
verb that has nothing to say. That is a convention question to settle, not a cleanup to do quietly.

**This is not a defect, so it is deliberately loose.** Nothing is broken; it is a simplification candidate. It is
the kind of output the planned architecture-review skill (STORY-007) will file through `/tasks intake`.

**Linked 2026-10-06 by `/improve-architecture` (EPIC-008, author run at `30f9716`) as two duplicate findings:**

Candidate key: 2:skills/tasks/verbs/help.md — IA-3
Candidate key: 2:skills/feature/verbs/help.md — IA-4

For each of the two findings (the same shape, one per router):
- **Files:** `skills/tasks/verbs/help.md` (IA-3) / `skills/feature/verbs/help.md` (IA-4), each with its only caller, its router (`skills/tasks/SKILL.md` / `skills/feature/SKILL.md`).
- **Problem:** class 2, shallow interface, raised on the deletion test's signal in a hot spot (`skills/tasks/verbs` 150 touches, `skills/feature/verbs` 57). The file holds one behaviour, printing the verb table, which its router already states.
- **Solution:** delete it, or merge it into the router. `Deletion test: concentrates — callers checked: skills/tasks/SKILL.md` (IA-4: `skills/feature/SKILL.md`). Inlining removes the file and grows no caller.
- **Benefits:**
  - Leverage: 1 router stops pointing at a file that repeats it.
  - Locality: 2 → 1 files per change to the help verb, with every other caller of the router untouched.
- **Before/after:** before, `router → help.md` (one arrow, one box that repeats the router). After, `router` alone, the help verb stated in its table row.
- **Strength:** `moderate`. The signal and the gate hold, with no fix landing in these files.

`specs/verbs/help.md` was outside this run's scope, so it is neither raised nor rejected.

## Acceptance criteria

- [x] The deletion test is run on each of the three `help.md` files, and each outcome (concentrates or merely moves) is recorded here with the caller checked
- [x] For each file that concentrates, the task either folds it into its router (router table row and any links updated, nothing else lost) or records why the one-file-per-verb convention keeps it
- [x] If any file is folded, AGENTS.md § *Naming* says how a verb with no file is written in a router table
- [x] `bash .github/workflows/skills-lint.sh` passes (check 3: every file a `SKILL.md` references exists)

## Out of scope

- Any other verb files, and the architecture-review skill itself (TASK-076)

## Human test plan

- [x] With the change installed, run `/tasks help`, `/specs help` and `/feature help` in a real repo. Confirm each prints its full menu, including the hint line any folded file carried
  - **Passed 2026-11-14**, by cold drills (`claude -p --disable-slash-commands`, cwd holding only `skill/`, `brief.txt` and
    an empty `repo/`; each runner listed no skills) rather than an installed run, since a help verb reads no repo.
    - **d261:** `/tasks help` printed the table and its hint; `/specs help` printed `No usable spec map` (fixed below);
      `/feature help` printed its menu, its file contradicting itself (fixed).
    - **d261b:** all three printed their full menus.
    - **d261c:** `/tasks help` printed one `<verb> — <what it does>` line per row and the hint; the other two as before.
- [x] For a file that was folded, confirm its router row still tells a reader what the verb does, with no dangling link
  - **Passed 2026-11-14**: the `/tasks` `help` row states the whole verb and reads `— (this row is the whole verb)` in its
    File cell; no file in `skills/`, `.github/`, the installers or `docs/` links `skills/tasks/verbs/help.md`; lint check 3
    passes.

## Implementation plan

Inline: run the deletion test on each file, fold the one that concentrates, record why the other two stay.

## Outcome

**The deletion test, file by file (callers checked: each file's router, `skills/`, `docs/`, `.github/`, the installers):**

| File | Outcome | Done |
|---|---|---|
| `skills/tasks/verbs/help.md` | **concentrates.** The router already said "print the verb table above and exit"; only the hint line was left | **folded**: the router row is the whole verb, the file is deleted |
| `skills/specs/verbs/help.md` | **merely moves.** It holds a fixed menu (the regen flag forms, a footer) that lives nowhere else | **kept** |
| `skills/feature/verbs/help.md` | **merely moves.** Its fixed menu adds the lifecycle line and the `/feature pick` hint, which live nowhere else (IA-4 judged it on the router line alone) | **kept** |

**AGENTS.md § Naming** now says how a verb with no file is written: `— (this row is the whole verb)` in the File cell,
the row stating everything. It also says to keep a file that holds text found nowhere else.

**Found by this task's drills, fixed in it:**
- **`/specs help` could not run without a map** (d261): the router's no-map guard excepted only `init`, so a user
  with no map got `No usable spec map` where the menu should be. `help` is now excepted too.
- **`feature`'s help file contradicted itself** (d261): its first sentence said to print SKILL.md's table, while it held
  a different menu. It now prints its own block, and says the menu is a short form of the table to keep in step.
- **Router rows said "Print the verb table"** for `specs` and `feature` while their files print a fixed menu (d261b).
  Both now read "Print the fixed menu its file holds".
- **Two-runner readings** (d261 and d261b): which form of the `/tasks` table to print, and whether the hint line's
  outer backticks are part of it. The row now prints one `<verb> — <what it does>` line per row, without its own row,
  then the line `Bare /tasks shows the status snapshot.`.
- **Two-runner reading** (d261b and d261c): whether a menu's fence lines are part of it. Both menu files now say
  "the text inside the code block, without its fence lines". Checked by reading.

**One-runner readings left unfiled** (FEATURE-002 D10): d261c's "plain list" (markup kept or stripped), the
`block / unblock` row, and the three help verbs being defined three ways.

**Close gate (inline; three routers, three verb files, AGENTS.md and three specs):**
- **Standards:** the new Naming sentence is the rule for a fileless verb.
- **Intent:** all criteria met.
- **Correctness:** d261, d261b, d261c.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** specs-from-code (help runs without a map), feature-lifecycle (the fixed menu), and work-tracking (the
  deleted file dropped from its sources). Restamped.

## Progress log

- step 2 — picked; the last P3 task in the pool (findings IA-3, IA-4); loose, no parent to roll up
- step 3 — re-verified: tasks' file concentrates into its router line; specs' and feature's files hold menu text found nowhere else
- step 5 — folded tasks/verbs/help.md; kept the other two; AGENTS.md § Naming states the fileless form
- step 6 — behavioural: d261 (two defects found, fixed), d261b (all three menus print), d261c (the tasks form settled)
- step 7 — respecced specs-from-code and feature-lifecycle, dropped the deleted source from work-tracking, restamped
- step 8 — closed inline; commit in git log
