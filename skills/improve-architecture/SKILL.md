---
name: improve-architecture
description: Review the shape of the code itself, not a feature or a defect — scope by the user's direction or by commit-history hot spots, surface deepening opportunities, and keep only candidates that survive the deletion test and respect the project's decision records. Use when the user says "/improve-architecture", "improve the architecture", "architecture review", "find refactoring opportunities", "where is the code shallow", "what should we deepen", "zlepši architektúru", "nájdi miesta na refaktoring", "kde je kód plytký", "prehodnoť architektúru". Distinct from [[verify-conventions]] (lints a diff against the rulebook) and [[code-review]] (judges correctness).
---

One subject: **the shape of the code.** Every other entry point reviews a feature or a defect, so structural
friction gets noticed and never addressed. This pass makes the codebase itself the thing under review.

Its output is two lists, and both matter: the **candidates** that survived the filter, and **everything the
filter rejected**, with the reason. A pass that prints only survivors cannot show that its filter
discriminates, and a reader cannot tell a careful review from one that reported every small module.

**One invariant is restated here because it is load-bearing: a small module is not a defect by itself.**
Smallness is a reason to look. The gate (Step 5) decides.

The vocabulary this skill applies is owned by [[tdd]]: [deep-modules.md](../tdd/deep-modules.md),
[interface-design.md](../tdd/interface-design.md) and the smell inventory in
[refactoring.md](../tdd/refactoring.md). **Point at those files; never copy their rows or signals here.** A copy
goes wrong silently the day a row is added there.

## Invocation

```
/improve-architecture               scope from the commit history (Step 3, rung 2)
/improve-architecture <direction>   a path, a module or a concept the user wants examined
```

## Step 1 — Read what is already settled

Before scanning anything, collect what earlier runs and earlier decisions already answered.

- **Earlier runs of this pass.** Find them **by declaration, never by title**: EPIC files with
  `kind: review-intake` whose `source:` names `improve-architecture`. An intake epic whose `source:` names no
  pass at all is listed in the header as `unattributed intake epic: EPIC-NNN — not read`, never skipped
  silently: it may be an earlier run filed without its name.
- **From each earlier run, read three things:**
  - its `### Findings dropped at intake` list: the rejections Step 5 re-checks;
  - its **open** tasks: a candidate whose key (`<n>:<path>`, the class number and the main file's path, written on each filed task by the handoff)
    matches one is not raised again, and is reported as `already filed: TASK-NNN`;
  - its **done** tasks: a candidate whose key matches one **is** raised, marked `recurs after TASK-NNN`. The
    earlier fix did not hold, which is a regression, not a duplicate.
- **Decision records.** Read every record in `docs/adr/` except the retirement ledger (`0000-retired.md`) and any
  record that says it is superseded, or that another record says it supersedes. [[domain]] § *Shape* owns what a
  record holds; this pass uses its *Decision* and its *Rejected alternatives*. **Never hard-code how many records
  there are**: the directory is the answer.
- No `docs/adr/` directory, or no earlier run: say so in one line and continue. Both are normal.

## Step 2 — Measure the history

Every rung in Step 3 and the friction check in Step 6 read these measurements, so take them first, whatever the
scope will be.

1. **Window:**
   ```
   git log --since=6.months --no-merges --format=@%h --name-only
   ```
   Each commit starts with a line `@<hash>`, followed by its files; the `@` lines are what keep commits apart.
   When the window holds fewer than 30 commits, drop `--since` to use the whole history, and say so in the header.
2. **Filter before counting**, or the ranking measures bookkeeping:
   - keep only paths `git ls-files` still lists. Renamed paths are not followed, so history under an old path is
     dropped; when the window spans a large rename, say so in the header, because the renamed area will look
     younger than it is;
   - drop generated and vendored files, by the ladder [[verify-conventions]] step 2b owns (read the
     project's declaration first; never a built-in list);
   - drop the project's documentation and tracking records: the task tree wherever the project's task root is,
     and the documentation rows of [[new-project]]'s layer inventory (`LAYER.md`), such as `docs/`, the changelog
     and the agent guide. **Keep its code rows** (the CI gate, the test harness, build files): they are code, and
     class 3 reads the tests. Records change with the bookkeeping, not with the code's shape.
     Measured on the repo this skill was written in: the generated task dashboard was the most-touched file of
     the window at 225 touches, and once the record trees were dropped the agent guide still topped the list at
     72, more than twice the next file.
3. **Rank:** count touches per file, then sum each file's count into its parent directory (files at the root count
   under `.`). Rank the directories. A **hot spot** is a directory touched at least twice as often as the median
   *touched* directory. Keep at most five, highest first, and name the top files inside each.
   - **When the bar cannot discriminate, there is no hot spot.** If the median touched directory has two touches or
     fewer, or fewer than five directories were touched at all, twice the median is noise. Do not take the top
     few anyway: that is an arbitrary pick between near-ties. Report `bar degenerate (median N)`, and Step 3 goes
     to rung 3. A ranking that quietly passes everything reads as a measurement it is not.
4. **Two signals the classes read:**
   - **co-change pairs:** two files appearing under the same `@<hash>` in at least 5 commits, where those shared
     commits are at least half of the less-touched file's commits;
   - **fix landings:** the files changed by commits whose **subject line** names a fix, over the same window and
     filter. `--grep` searches the whole message, so it cannot be used for this: a body that mentions a fix is not
     a fix. List the subjects, `git log --since=6.months --no-merges --format="%h %s"`, and keep the commits whose
     subject contains `fix`, `fixes`, `fixed`, `bug`, `bugs`, `regress` or `regression` as a **whole word**, where
     a hyphen does not end a word. Without the boundaries, `fix` matches "prefix" and "fixture", `bug` matches
     "debug", and a hyphenated name such as `fix-next` reads as a fix. Then take the files of each kept commit
     from the window's output. Drop `--since` here too when the window was widened.

## Step 3 — Scope: an ordered ladder

Take the first rung that applies, and **name the rung in the report's header**, so a reader can tell a
user-chosen scope from a measured one.

| Rung | When | Scope |
|---|---|---|
| 1 | the user named a direction | that path, module or concept, and nothing else |
| 2 | no direction | the hot spots from Step 2, examined first |
| 3 | no direction, and Step 2 found no hot spot | the whole tree, breadth-first |

**Why hot spots come first:** deepening pays off only where change is coming. A beautifully restructured module
nobody touches again returned nothing.

**Rung 1 — a direction.** Resolve it against `git ls-files` (a path) or the code's own names (a module or concept).
Step 2's measurements are always taken over the whole repo: rung 1 restricts where candidates are looked for,
never what counts as a hot spot. Measured inside a single path, every directory in it would clear the bar, and
Step 6 would read friction everywhere.
- **It matches more than one place.** Put this question:
  > **`<direction>` matches `<list>`. Scan one of them, several, or all?**

  No answer, or nobody to ask: scan all of them, and the header says the direction was ambiguous and lists what
  was scanned.
- **It matches nothing.** Put this question:
  > **`<direction>` matches no path or name in this repo. Name a path, or fall back to the commit-history hot spots?**

  No answer, or nobody to ask: fall to rung 2, and the header records that the direction matched nothing.

**Rung 3 — no hot spot.** A scattered history is a result, not a dead end, and it is reported as one. Put the
measurement in the header (`most-touched: N touches, median M — no hot spot`), then scan every top-level area
breadth-first and list the areas covered. **Never pick an area arbitrarily and present it as a hot spot.**

## Step 4 — Candidates, by class

Each class names the **signal you look at** to decide it applies. Where the signal is owned elsewhere, the row
points there.

| Class | Observable signal | Owned by |
|---|---|---|
| **1. Concept scatter** | following one use case through the code touches four or more files, each adding a few lines, and those files form co-change pairs (Step 2) | *Shotgun surgery* in [refactoring.md](../tdd/refactoring.md) |
| **2. Shallow interface** | the deletion test's signal, or an interface with one adapter (a base class with exactly one subclass counts as one adapter) | [deep-modules.md](../tdd/deep-modules.md) § *The deletion test*; [interface-design.md](../tdd/interface-design.md) item 4 |
| **3. Tested in isolation, broken at the call** | a function with its own tests, while the fix landings (Step 2) in its area change its **callers**, not the function | this skill |
| **4. Leaky seam** | a co-change pair that crosses a module boundary, or one module reading another's internals or storage shape | *Feature envy* and *Message chains* in [refactoring.md](../tdd/refactoring.md) |
| **5. Untestable through its interface** | the signal of [interface-design.md](../tdd/interface-design.md) item 5 | item 5 |

**A smell in [refactoring.md](../tdd/refactoring.md) that fits none of these classes is not this pass's
finding.** Leave it out rather than stretching a class to hold it; [[verify-conventions]] applies that inventory
to a diff.

*Design it twice* ([interface-design.md](../tdd/interface-design.md) § *Design it twice*) is not a class: a
reviewer sees only its late form. Use it when drafting the interface a candidate proposes.

Each candidate records: its key (`<n>:<path>`: the class number from the table above and the path of its main file), its class, the files, the evidence
for the signal (counts, commit hashes, paths), and its gate result from Step 5.

## Step 5 — The gate on every candidate

**Every candidate states which test judged it, and its answer.**

**The gate is chosen by the signal that raised the candidate, and exactly one applies:**

- **A class 2 candidate raised on the deletion test's signal** goes through
  [deep-modules.md](../tdd/deep-modules.md) § *The deletion test*:

  ```
  Deletion test: <outcome> — callers checked: <paths>
  ```

  | Outcome, per that section | Result here |
  |---|---|
  | concentrates (any number of callers) | **candidate**: delete or merge |
  | merely moves, two or more callers, interface still shallow | **candidate**: deepen |
  | merely moves, two or more callers, interface not shallow | **rejected**, with its record (below) |
  | merely moves, one caller | the *Speculative generality* row of [refactoring.md](../tdd/refactoring.md) decides, and is named: **candidate** (inline it) when no second caller is in sight, otherwise **rejected** |
  | a data shape | **rejected** as a data shape, so it is not raised again |

  **That section owns the outcomes; this table only maps them.** If it names an outcome the table lacks, report
  the outcome by its own name and leave the candidate undecided (`Deletion test: undecided — <outcome>`), rather
  than forcing it into a row.
- **A class 2 candidate raised on one adapter** is judged by [interface-design.md](../tdd/interface-design.md)
  item 4 instead, which counts implementations rather than callers: `Item 4: <n> implementation(s) — <result>`.
- **Classes 1, 3, 4 and 5** stand on their own signal, even when their move merges files:
  `Gate: not a shallowness claim — <class>`.

**A rejection is recorded, so the next run does not raise it again.** Record callers as paths:

```
- <path> — <reason> (callers: <paths>; at <commit>)
```

`<commit>` is `git rev-parse --short HEAD` when the test ran. The durable home of the record is the dropped
findings list of the intake epic this run's findings are filed into. Until a run's findings are filed, the
report is the record's only copy; say so in the report. **Never record it in a code comment**: that is a QA log,
and the next pass does not read comments.

**A recorded rejection suppresses the candidate, never the check.** It is a derived verdict: it holds only while
the code it judged is unchanged. For each deletion-test rejection Step 1 found, re-check it (a `held by ADR`
entry is not re-checked here: Step 6 recomputes it every run, because it turns on the history, not on the code):
1. run `git log <commit>..HEAD --format=%h -- <path> <callers>`;
2. find the module's callers again, as paths.

If the log printed nothing **and** the caller list is the one recorded, report
`previously rejected, unchanged since <commit>` and do not re-run the test. If the log printed anything, the
callers differ, or git cannot resolve `<commit>` (the history was rewritten), run the test again and record the
new result.

## Step 6 — Decision records

**A move contradicts a record** when it would reinstate one of the record's *Rejected alternatives*, or undo its
*Decision* in the area the move names. Apply this to every move a record blocks, **including one you set aside
before it became a candidate because of the record**: the friction check below decides whether it is surfaced,
not the order you met it in.

**It is surfaced only on real friction.** Real friction is Step 2 evidence attributable to that decision: the
area is a hot spot, or fix landings cluster there. Cite the commits. Under rung 3 there is no hot spot, so only
the fix landings can show friction.

| Friction | Do |
|---|---|
| present | surface the candidate marked **`contradicts ADR NNNN — <title>`**, citing the evidence, and recommend reopening the record through [[domain]]. Never propose the code change alone, as if the record did not exist |
| absent | do not propose it. List it among the rejected as **`held by ADR NNNN — <title> (at <commit>)`** |

**"Held by" is derived too, so it is never settled.** Friction is evidence the repo still holds, so every run
recomputes it for each held move, whatever an earlier run recorded. A move held today is surfaced the run its area
becomes a hot spot.

Never silently propose a change a record rejected. That is how a settled trade-off gets re-argued by accident.

## Output

*Minimal by design: the report's full shape is owned by the report surface, which replaces this section.*

```
improve-architecture — scope: <rung and what it covered; direction ambiguous / matched nothing>  (<the measurement; bar degenerate; renames>)
already settled: <n> earlier runs read, <n> decision records read  [unattributed intake epic: EPIC-NNN — not read]
records: <filed into EPIC-NNN | not filed yet — this report is the only copy of the rejections below>

Candidates
  <n>. <class> — <files>   key: <n>:<path>   [recurs after TASK-NNN]
       evidence: <counts, commits, paths>
       <the gate line from Step 5, including `undecided — <outcome>`>
       [contradicts ADR NNNN — <title>]

Rejected
  - <path> — <reason> (callers: <paths>; at <commit>)
  - <path> — held by ADR NNNN — <title> (at <commit>)

Previously rejected, unchanged
  - <path> — since <commit>

Already filed
  - <key> — TASK-NNN
```

Print every section even when it is empty, with `(none)`. A section that disappears when it has nothing in it
cannot be told apart from a section that was never computed.

## What this skill does NOT do

- Judge correctness. That is [[code-review]].
- Lint a change against the rulebook. That is [[verify-conventions]].
- Reopen a decision record. It recommends it; [[domain]] does it.
- Change code. Its output is candidates for tracked work.

## Related skills

- [[tdd]] — owns the deletion test, the interface rules and the smell inventory this pass applies.
- [[domain]] — owns decision records: what a record holds, and how one is superseded.
- [[tasks]] — `intake` is where a run's findings become tracked work, and where its rejections are kept.
- [[fix-next]] — drains the tasks a run files.
