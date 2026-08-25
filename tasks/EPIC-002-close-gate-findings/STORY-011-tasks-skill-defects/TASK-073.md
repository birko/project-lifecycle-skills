---
id: TASK-073
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-23
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# Should the task template stop carrying an enum comment that shadows its own field?

## Context

**Spawned from TASK-036's out-of-scope sweep, 2026-08-23.** TASK-036 fixed the *reader*: `/specs regen` now
names the leading enum comment explicitly and gives the anchored, frontmatter-scoped pattern. This task asks
the question one level up, which that fix deliberately left open.

`skills/tasks/templates/task.md` emits, on **every** task file:

```
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
```

The comment contains **every legal value**, one line above the field it documents. That is what makes it a
trap: any unanchored read or write that matches `status:` hits the comment first, and the comment parses as
`todo`.

**Two instances, both measured, and they point in opposite directions on the fix:**

- **Read side** (TASK-036's original finding): an unanchored first-match read returns `todo` for *every*
  template-generated task, including the `done` ones — so `/specs regen` would conclude the work never
  landed and refuse the commit's evidence.
- **Write side** (2026-08-23): a `/fix-next` run set its pick with an unanchored substring replace, rewrote
  the **comment** instead of the field, and ran the task to completion — fix, verification, a full
  `## Outcome` — while its frontmatter still read `todo`. Caught only because a task count came out one
  short.

**The question this task owns.** TASK-036's answer was *teach every reader and writer to anchor*. The
alternative is *remove the shadow*: the hazard exists only because the comment sits adjacent to the field
and duplicates its value space. Options, and none is obviously right:

| Option | Cost |
|---|---|
| **Keep it, rely on anchoring** (status quo after TASK-036) | Zero change, and the trap stays armed for every future reader and writer. Two instances in two days is not a reassuring base rate. |
| **Delete the comment** | Kills the hazard at source. Loses the one place a task author sees the legal values — and `status` is the field most likely to be hand-typed wrongly. Where does the vocabulary get documented instead? |
| **Move it away from the field** — e.g. one comment block at the top of the frontmatter, or below the last field | Keeps the documentation, breaks the adjacency that makes first-match land on it. Cheapest real fix, and it still leaves a line containing every value somewhere in the file. |
| **Reword so it cannot parse as a value** — e.g. `# status — one of: todo, in-progress, …` | The comment no longer looks like `status: <value>`, so a `status:` match cannot hit it at all. Keeps documentation *and* adjacency. |

**The last option looks strongest and should still be argued rather than assumed** — it changes a template
every existing task file already carries, so consider whether existing files get migrated or left, and say
which. `/tasks triage` and `/tasks close` both read these files.

**Note this is a template change, not a rule change.** The vocabulary itself is normative and lives in
[[tasks]] § Lifecycle; the comment is a convenience copy of it — which is its own small instance of the
*defer to a shared inventory* rule, worth naming in whichever direction this lands.

## Acceptance criteria

- [ ] A decision is recorded: keep / delete / move / reword, with the reason and the rejected options
- [ ] If the template changes, it is stated whether existing task files are migrated or left as-is — and if left, that mixed state is safe for every reader
- [ ] Whatever lands, an unanchored `status:` match can no longer return a legal-looking value from a non-field line — or the task records that it still can and why that was accepted
- [ ] The legal-value vocabulary remains discoverable to someone writing a task by hand, wherever it ends up
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- `/specs regen`'s read pattern — **TASK-036**, closed. This is the source-side question.
- The status vocabulary itself. Adding or removing a state is a different change entirely.
- Other frontmatter comments (`# findings:`, `# theme:`, `# kind:`). Check whether they share the shape and **spawn** if so; only `status:` has two measured instances, and only it duplicates a closed value set.

## Human test plan

- [ ] Create a task with `/tasks new` and confirm a hand-author can still tell what values `status:` accepts
- [ ] Run an unanchored `grep -m1 'status:'` over the new file and confirm the result is not a legal-looking value (or that the accepted residual risk is recorded)
- [ ] Run `/tasks triage` and `/tasks close` against both a migrated and an unmigrated file if the two shapes are allowed to coexist

## Implementation plan

_Populated by `/tasks plan TASK-073` — leave empty until then._
