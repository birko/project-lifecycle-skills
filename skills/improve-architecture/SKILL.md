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
  - its `### Findings dropped at intake` list: the rejections Step 5 re-checks. Match its entries **by key, never
    by path**: two members of one file are two entries;
  - its **open** tasks: a candidate whose key (as Step 4 defines it; the handoff writes it on each filed task)
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
| 2 | no direction | the hot spots from Step 2, then the second tier below |
| 3 | no direction, and Step 2 found no hot spot | the whole tree, breadth-first |

**Why hot spots come first:** deepening pays off only where change is coming. A beautifully restructured module
nobody touches again returned nothing.

**Rung 2 has two tiers, and both are fixed lists**, so two runs over an unchanged repo scan the same files:
1. **the hot spots**;
2. **then every file outside them** that is in a co-change pair or touched by a fix landing (Step 2 measured both
   over the whole repo). Change is coming there too; it is just spread thinner.

Nothing outside those two lists is scanned under rung 2. The header names both tiers and their sizes
(`hot spots: <list>; then <n> files from co-change pairs and fix landings`). The report lists second-tier
candidates after the hot-spot ones; that is a sort by tier, never a ranking, and strength is untouched by it.

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

| Class | Observable signal | Its move | Owned by |
|---|---|---|---|
| **1. Concept scatter** | following one use case through the code touches four or more files, each adding a few lines, and those files form co-change pairs (Step 2) | pull the scattered pieces into one module | *Shotgun surgery* in [refactoring.md](../tdd/refactoring.md) |
| **2. Shallow interface** | the deletion test's signal, or an interface with one adapter (a base class with exactly one subclass counts as one adapter) | the move Step 5's gate chooses: delete or merge, deepen or inline (the deletion test), or depend on the concrete type, or return the result instead of calling back (item 4) | [deep-modules.md](../tdd/deep-modules.md) § *The deletion test*; [interface-design.md](../tdd/interface-design.md) item 4 |
| **3. Tested in isolation, broken at the call** | a function with its own tests, while the fix landings (Step 2) in its area change its **callers**, not the function | move what the callers keep correcting into the function, so the tested surface is the one that breaks | this skill |
| **4. Leaky seam** | a co-change pair that crosses a module boundary, or one module reading another's internals or storage shape | move the logic to where the data lives, or ask the owning module for what is wanted | *Feature envy* and *Message chains* in [refactoring.md](../tdd/refactoring.md) |
| **5. Untestable through its interface** | the signal of [interface-design.md](../tdd/interface-design.md) item 5 | change the interface until the behaviour can be seen through it | item 5 |

**A module** is the unit the build declares above a single file: a project, a package, a crate. Where the build
declares none, it is the directory. Never a single file, even in a language that calls each file a module: two
files changing together inside one package is ordinary cohesion, not a leaky seam. Class 4's boundary and the
report's frames both use this definition.

**Every candidate collects two sets of paths around it**, whatever its class, because the report counts both:
- **its callers**: the files that call or import what the candidate is about (the function, the interface, the
  module);
- **its co-change partners**: the files that changed together with its main file (Step 2's pairs), and for
  class 1 the files of the use-case trace.

A set that cannot be built (callers reached through dynamic dispatch or reflection, or users outside the repo)
is recorded as incomplete.

**A smell in [refactoring.md](../tdd/refactoring.md) that fits none of these classes is not this pass's
finding.** Leave it out rather than stretching a class to hold it; [[verify-conventions]] applies that inventory
to a diff.

*Design it twice* ([interface-design.md](../tdd/interface-design.md) § *Design it twice*) is not a class: a
reviewer sees only its late form. Use it when drafting the interface a candidate proposes.

Each candidate records its **key**: `<n>:<path>` (the class number and its main file's path), with `#<member>`
appended whenever the candidate concerns one member rather than the whole file: a method, event, property,
injected dependency or nested type, named by its identifier as written in the code (so overloads are one member).
Whether the suffix applies depends on the candidate alone, never on what else this run found in the file, or a
later run that finds a second member keys the first one differently and matches nothing. Two candidates of one
class on one file, neither about one member, are one candidate. A renamed member, or a candidate that narrows
from file to member, gets a new key and reads as new: renames are not followed here, as they are not in Step 2.
To read a key back, the class runs to the first `:`; the member is what follows the last `#`, but only when that
text holds no `/` and no `.` (an identifier never does), and otherwise the `#` belongs to the path; in an entry
the key ends at the first ` — `.

It also records its class, the files, the evidence
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
  `Gate: not a shallowness claim — <class>`. A closer look can still kill the signal: the commit that made a
  co-change pair was later undone and fewer than 5 shared commits remain; the trace's files serve separate use
  cases; the callers' fixes are unrelated to the function; the behaviour is visible through the interface after
  all. The gate line is then `Gate: signal fails — <class> — <the commit or paths that show it>`, where a class 4
  `<class>` also names the signal it was raised on (`4, co-change` or `4, internals`), and the
  candidate is rejected with its record. **Never kill a signal without naming that evidence**: a judgement with no
  evidence cannot be re-checked.

**A rejection is recorded, so the next run does not raise it again**, in the shape `/tasks intake` step 3 states:

```
- <key> — <reason> (callers: <paths>; at <commit>)
```

`<reason>` is the gate line from above, verbatim (`Deletion test: …`, `Item 4: …`, or `Gate: signal fails — …`),
so a re-check reads off it which gate to re-run and which set the slot holds. The `callers:` slot holds the paths
the verdict turned on, reusing the two sets Step 4 collected (the label stays `callers:` for every gate, so the
contract does not change shape). Separate the paths with `, `; end an incomplete set (Step 4) with `, incomplete`,
and a re-check then compares only the listed part:

| Gate | `callers:` holds |
|---|---|
| deletion test; class 3; class 5 | its callers |
| item 4 | the implementations |
| class 1; class 4, co-change | its co-change partners |
| class 4, internals | its callers |

Write `none` when the set is empty. **Record the whole set**: every caller, every implementation, or every
co-change partner of the key's path (the trace's files are evidence, not the slot), never only the ones this
candidate happened to be raised on. A partial record reads as changed on every later run.

`<commit>` is `git rev-parse --short HEAD` when the test ran. The durable home of the record is the dropped
findings list of the intake epic this run's findings are filed into. Until a run's findings are filed, the
report is the record's only copy; say so in the report. **Never record it in a code comment**: that is a QA log,
and the next pass does not read comments.

**A recorded rejection suppresses the candidate, never the check.** It is a derived verdict: it holds only while
the code it judged is unchanged. Re-check every rejection Step 1 found, except `held by ADR` (Step 6 recomputes
that one every run, because it turns on the history, not on the code):
1. if `git ls-files` no longer lists the key's path, report `rejected file gone: <key> (since <commit>)`;
2. if the key names a member the file no longer has, report `rejected member gone: <key> (since <commit>)`;
3. run `git log <commit>..HEAD --format=%h -- <the key's path> <callers>` (with `callers: none`, the path alone);
4. for a callers or implementations slot, rebuild the set and compare it with the slot. **A co-change slot is not
   rebuilt**: a new partner needs a commit to the key's path, which step 3 already sees, while a pair that ages out
   of Step 2's window is not a change to the code.

A gone entry (steps 1–2) is reported and not re-tested; this skill never edits the earlier run's record, so the
entry stays there until the run that files these findings records the outcome. Otherwise, if the log printed
nothing **and** any rebuilt set is the one recorded, report `previously rejected, unchanged since <commit>` and do
not re-run the gate. If the log printed anything, a set differs, or git cannot resolve `<commit>` (the history was
rewritten), re-run the gate the reason names and record the new result.

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
| absent | do not propose it. List it among the rejected as **`<key> — held by ADR NNNN — <title> (at <commit>)`**; a move set aside before it became a candidate takes the key it would have had |

**"Held by" is derived too, so it is never settled.** Friction is evidence the repo still holds, so every run
recomputes it for each held move, whatever an earlier run recorded. A move held today is surfaced the run its area
becomes a hot spot.

Never silently propose a change a record rejected. That is how a settled trade-off gets re-argued by accident.

## Output — the report

### Delivery: the analysis never depends on the surface

This is the rule `/tasks close` step 5b applies to a review skill the runtime does not provide: **a missing
runtime capability degrades the means or the delivery, never the pass.** There, the review is run inline; here,
the report is delivered as a file. A run that ends with no report because it could not
publish one is the failure this rule prevents.

1. **Always write the page first**, to `<tmp>/improve-architecture-<repo>-<short HEAD>.html`. `<tmp>` is the
   scratch directory the runtime designates, else the system temp directory (`$TMPDIR`, `%TEMP%`, else `/tmp`).
   **Never write it inside the repo**: it would be committed by accident, and the next run's `git ls-files` would
   count it. The page is one self-contained file, with inline CSS and SVG and nothing fetched from the network, so
   it opens in a browser with nothing installed.
2. **Publish it** when this session's tool list includes a tool that publishes an HTML page as a link only the
   user can see (in Claude Code, `Artifact`). Decide from the tools this session actually has, never from the
   runtime's name. Publish it private, and never share it or widen who can see it: sharing is the user's act. A
   surface that cannot publish privately counts as absent.
3. **No such tool, or a publish that errors or returns no link, ends the same way:** the temp file is the report.
   Print its absolute path and the reason (`no publishing surface`, or `publish failed: <error>`).

Nothing is asked before publishing. The publishing tool belongs to the runtime this session already sends the
repository's code to, and the page it makes is private; a question would also send every unattended run down
the fallback path. When the publishing tool sets its own rules for a page (a design pass, colour modes), follow
them for the published copy; the temp file stays as written.

### Every candidate, one shape

Every candidate fills every part. A part with nothing in it says `none — <why>`; it is never left out, because a
missing part cannot be told from a part nobody looked for.

| Part | Holds | From |
|---|---|---|
| **Files** | the candidate's files, main file first; its key (Step 4); `recurs after TASK-NNN` when Step 1 found one | Steps 1, 4 |
| **Problem** | the class, and the evidence for its signal: counts, commit hashes, paths | Step 4 |
| **Solution** | the candidate's move (Step 4's table: the class's own move, or the one the gate chose for class 2); the gate line verbatim; and, when it applies, `contradicts ADR NNNN — <title>`, with reopening that record through [[domain]] as the first step | Steps 5, 6 |
| **Benefits** | one line for leverage and one for locality, below | Steps 2, 4, 5 |
| **Before/after** | the visual, below | Steps 2, 4, 5 |
| **Strength** | `strong`, `moderate` or `tentative`, and the evidence that set it, below | Steps 1, 2, 4, 5 |

### Benefits: leverage and locality, and nothing else

These are the two quantities a reader weighs against the cost of the refactor. A benefit phrased any other way
("cleaner", "more maintainable") cannot be compared with the next candidate's, so it is not written.

- **Leverage — how much else gets easier.** The callers (Step 4) that stop carrying a pass-through, a
  workaround or a copy, counted and named: `Leverage: 4 callers lose their retry copy — <paths>`.
- **Locality — how much stays put.** The files one change to this concept touches today and after the move (its
  co-change partners, Step 4), and how many of its callers the move itself leaves untouched:
  `Locality: 5 → 1 files per change; 9 of 11 callers untouched`.

Report the two side by side and never combine them into one score: a score is a ranking, and ranking happens
downstream. A figure the run could not count is written `not measured — <why>`, never filled with an adjective.

### The before/after visual

Two panels on the same layout, so the only differences between them are what the move changes:

- **a box per file** in Files, labelled with its path. Callers outside the list share one box, `callers (n)`,
  naming them when there are three or fewer;
- **solid arrows** for the calls and imports among the boxes, from the paths Step 4 collected around the candidate;
- **dashed lines** for co-change pairs, labelled with the shared-commit count (Step 2);
- **a frame** around each module (as Step 4 defines one), so the seam a class 4 candidate crosses is visible.

The **after** panel draws the candidate's move (Step 4's table, or the gate's choice for class 2). Merged boxes
become one, deleted boxes are gone, moved logic shows as an arrow that no longer crosses a frame, and a deepened
module shows its interface
as a thin strip on top of a large body (the picture in [deep-modules.md](../tdd/deep-modules.md)). The boxes and
edges the move changes are highlighted and everything else is grey: the grey is the locality line, drawn. At most
twelve boxes a panel; more fold into `+n more`. Under each panel, the same content as text
(`A → B; A → C; A ~ B (7 commits)`), for a reader whose browser does not draw the picture. How it is drawn is the
runtime's choice; what it shows is fixed here.

### Strength: confidence that the candidate is real, never priority

Read the rows in order and take the first that matches, so exactly one applies:

| Strength | When |
|---|---|
| `tentative` | the gate is undecided, or a set of paths around the candidate (Step 4) is incomplete |
| `strong` | otherwise, when the history corroborates the candidate with evidence **other than the signal that raised it**: fix landings or `recurs after` for a candidate raised on co-change; co-change or `recurs after` for one raised on fix landings; any of the three, in the candidate's own files, for the rest |
| `moderate` | otherwise: the signal and the gate hold, with no history behind them |

**Nothing else moves it**: not hot-spot rank, payoff size, effort, a decision record, or properties of the scope
(the rung, a widened window, an ambiguous direction), which the header already reports. Those decide the order the
work is done in, and that order is blast radius, which [[fix-next]] computes from its own keys once
`/tasks intake` has filed the task. A strength that carried priority would pre-empt that ranking. So candidates
are listed by rung 2's tier, then by key (class number, then path), **never by strength**.

### The rest of the page

After the candidates, each as a plain table, and every one printed with `(none)` when empty:

- **the header**: the scope rung and what it covered (an ambiguous or unmatched direction), the measurement,
  `bar degenerate`, renames; what was already settled (earlier runs and decision records read, or that there were
  none) and any `unattributed intake epic`; and on its own line, in bold, the **records line**:
  `filed into EPIC-NNN`, or `not filed yet — this report is the only copy of the rejections below`;
- **Rejected**: one row per rejection, with its record line verbatim
  (`- <key> — <reason> (callers: <paths>; at <commit>)`, or the `held by ADR` form), so `/tasks intake` can copy
  it as it stands;
- **Previously rejected, unchanged**: `<key> — since <commit>`;
- **Rejections gone**: `<key> — rejected file gone | rejected member gone (since <commit>)`;
- **Already filed**: `<key> — TASK-NNN`.

### Stdout, whichever way the page was delivered

```
improve-architecture — scope: <rung and what it covered; direction ambiguous / matched nothing>  (<the measurement; bar degenerate; renames>)
already settled: <n> earlier runs read, <n> decision records read  [unattributed intake epic: EPIC-NNN — not read]
records: <filed into EPIC-NNN | not filed yet — this report is the only copy of the rejections below>

Candidates
  <n>. <class> — <main file>   key: <key>   strength: <strength> (<the evidence that set it>)   [recurs after TASK-NNN]
       evidence: <counts, commits, paths>
       <the gate line from Step 5>
       [contradicts ADR NNNN — <title>]

Rejected
  - <key> — <reason> (callers: <paths>; at <commit>)
  - <key> — held by ADR NNNN — <title> (at <commit>)

Previously rejected, unchanged
  - <key> — since <commit>

Rejections gone
  - <key> — rejected file gone | rejected member gone (since <commit>)

Already filed
  - <key> — TASK-NNN

report: <link> | <path> (<reason>)
```

Every section prints here too, with `(none)` when empty. The rejection sections print in full even when the page
holds them: until the run is filed they exist nowhere else, and a temp file can be cleaned away.

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
