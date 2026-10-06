---
area: code-shape-review
generated-at: 20c038b36b869ce21fee8cdd7d30bd0a8bcdfae9
generated-on: 2026-10-06
sources:
  - skills/improve-architecture/SKILL.md
shaped-by: []
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Reviewing the shape of the code itself, and filing what it finds as tracked refactor work

## Purpose

Code-shape review makes the structure of a codebase the thing under review, rather than a feature or a defect. It reads what earlier runs and decision records already settled, measures the commit history to find where change is concentrated, picks a scope by a fixed ladder, raises candidates in five classes (concept scatter, shallow interface, tested in isolation but broken at the call, leaky seam, untestable through its interface), puts every candidate through exactly one gate, and keeps both the survivors and every rejection with its reason. Its deliverable is tracked tasks in a `kind: review-intake` epic filed through `/tasks intake`, so the defect drain can pick them up; the report — a private page or a temp file, plus stdout — is provenance. The skill never changes code, never reopens a decision record itself, and never judges correctness.

## Requirements

### Requirement: Find earlier runs by declaration, never by title

The system SHALL find earlier runs of this pass only as EPIC files with `kind: review-intake` whose `source:` names `improve-architecture`, SHALL list any intake epic whose `source:` names no pass at all in the header as `unattributed intake epic: EPIC-NNN — not read`, and SHALL read the `### Findings dropped at intake` list of the latest earlier run only — the one with the highest EPIC id — matching its entries by key, never by path.

#### Scenario: Two earlier runs exist

- **Given** EPIC-040 and EPIC-052 both have `kind: review-intake` and a `source:` naming `improve-architecture`
- **When** the pass starts
- **Then** it reads the dropped list of EPIC-052 only, and treats that list as the complete set of standing rejections

#### Scenario: An intake epic names no pass

- **Given** EPIC-030 has `kind: review-intake` and `source: reports/arch.html`
- **When** the pass starts
- **Then** it does not read EPIC-030, and the header says `unattributed intake epic: EPIC-030 — not read`

#### Scenario: Two members of one file

- **Given** the dropped list holds `2:src/client.cs#Client::Save` and `2:src/client.cs#Client::Load`
- **When** the entries are matched to this run's candidates
- **Then** they are two separate entries, matched by their full keys

### Requirement: Candidates already tracked are suppressed, declined, or raised as regressions by task status

The system SHALL read the `Candidate key:` lines of every task whose `findings:` holds an `IA-*` id, and for a candidate whose key matches: SHALL not raise it and SHALL report `already filed: TASK-NNN` when the task is open (any status but `done` and `cancelled`, including `verify` and blocked); SHALL not raise it and SHALL report `declined: TASK-NNN` when the task is `cancelled`; and SHALL raise it marked `recurs after TASK-NNN` when the task is `done`.

#### Scenario: The matching task is at verify

- **Given** TASK-210 holds `IA-3`, reads `verify`, and carries `Candidate key: 2:src/a.ts#parse — IA-3`
- **When** this run raises a candidate with key `2:src/a.ts#parse`
- **Then** the candidate is not raised and is reported `already filed: TASK-210`

#### Scenario: The matching task was cancelled

- **Given** TASK-211 carries the matching key and reads `cancelled`
- **When** the candidate is found again
- **Then** it is not raised and is reported `declined: TASK-211`

#### Scenario: The matching task was done

- **Given** TASK-212 carries the matching key and reads `done`
- **When** the candidate is found again
- **Then** it is raised as a candidate marked `recurs after TASK-212`

### Requirement: Read every live decision record, never a hard-coded count

The system SHALL read every record in `docs/adr/` except `0000-retired.md` and any record that says it is superseded or that another record says it supersedes, SHALL use each record's *Decision* and *Rejected alternatives*, and SHALL never hard-code how many records there are.

#### Scenario: One record is superseded

- **Given** `docs/adr/` holds 0001, 0002 and 0003, and 0003 says it supersedes 0002
- **When** the pass reads decision records
- **Then** it reads 0001 and 0003 and not 0002 or `0000-retired.md`

#### Scenario: Nothing settled yet

- **Given** there is no `docs/adr/` directory and no earlier run
- **When** the pass starts
- **Then** it says so in one line and continues

### Requirement: Measure a six-month commit window, widening to the whole history when it is thin

The system SHALL take its history measurements before scoping, whatever the scope, from `git log --since=6.months --no-merges --format=@%h --name-only`, separating commits by their `@<hash>` lines, and SHALL drop `--since` to use the whole history, saying so in the header, when the window holds fewer than 30 commits.

#### Scenario: A young repository

- **Given** the last six months hold 18 non-merge commits
- **When** the history is measured
- **Then** the whole history is used and the header says the window was widened

### Requirement: Filter paths before counting touches

The system SHALL count only paths `git ls-files` still lists (not following renames, and saying so in the header when the window spans a large rename), SHALL drop generated and vendored files by the ladder `verify-conventions` step 2b owns, and SHALL drop the task tree and the documentation rows of the layer inventory (such as `docs/`, the changelog and the agent guide) while keeping its code rows (CI gate, test harness, build files).

#### Scenario: Bookkeeping files dominate raw counts

- **Given** the task dashboard was touched 225 times and the agent guide 72 times in the window
- **When** touches are counted
- **Then** neither file is counted, and a CI script touched 20 times is counted

#### Scenario: A file was renamed

- **Given** `src/old.py` was renamed to `src/new.py` within the window
- **When** touches are counted
- **Then** history under `src/old.py` is dropped, and if the rename is large the header says the renamed area will look younger than it is

### Requirement: Rank directories and name at most five hot spots against twice the median

The system SHALL count touches per file, sum each file's count into its parent directory (root files under `.`), rank the directories, and name as hot spots at most five directories touched at least twice as often as the median touched directory, highest first, with the top files inside each.

#### Scenario: A clear hot spot

- **Given** eight touched directories with a median of 6 touches, and `src/billing` at 30
- **When** the ranking runs
- **Then** `src/billing` is a hot spot, named with its most-touched files

### Requirement: A degenerate bar yields no hot spot

The system SHALL report `bar degenerate (median N)` and name no hot spot when the median touched directory has two touches or fewer, or fewer than five directories were touched, and SHALL then scope by rung 3 rather than taking the top few directories.

#### Scenario: Low median

- **Given** the median touched directory has 2 touches
- **When** the ranking runs
- **Then** no hot spot is named, the report says `bar degenerate (median 2)`, and the scope falls to rung 3

### Requirement: Measure co-change pairs

The system SHALL treat two files as a co-change pair when they appear under the same `@<hash>` in at least 5 commits and those shared commits are at least half of the less-touched file's commits.

#### Scenario: Shared commits below half

- **Given** `a.go` and `b.go` share 5 commits, and `b.go`, the less-touched, has 12 commits
- **When** co-change pairs are measured
- **Then** they are not a pair

### Requirement: Measure fix landings from commit subjects only, by whole word

The system SHALL identify fix commits by their subject line, never with `--grep`, keeping commits whose subject contains `fix`, `fixes`, `fixed`, `bug`, `bugs`, `regress` or `regression` as a whole word where a hyphen does not end a word, and SHALL take those commits' files from the window's output, over the same window and filter (widened when the window was).

#### Scenario: Look-alike words

- **Given** subjects `add prefix parsing`, `debug output`, `fix-next: rank by theme`, and `fix null check in parser`
- **When** fix landings are collected
- **Then** only `fix null check in parser` is kept

#### Scenario: Fix mentioned only in the body

- **Given** a commit with subject `refactor reader` and a body saying "this also fixes #12"
- **When** fix landings are collected
- **Then** it is not a fix landing

### Requirement: Scope by an ordered ladder, named in the header

The system SHALL take the first rung that applies — rung 1 when the user named a direction, rung 2 when no direction, rung 3 when no direction and no hot spot — and SHALL name the rung in the report's header.

#### Scenario: No direction, a hot spot exists

- **Given** `/improve-architecture` is run with no argument and Step 2 found two hot spots
- **When** the scope is chosen
- **Then** rung 2 is used and the header names it

### Requirement: Rung 2 scans two fixed tiers and nothing else

The system SHALL, under rung 2, scan the hot spots first and then every file outside them that is in a co-change pair or touched by a fix landing (both measured over the whole repo), SHALL scan nothing else, SHALL name both tiers and their sizes in the header, and SHALL list second-tier candidates after hot-spot ones without that order affecting strength.

#### Scenario: A file outside hot spots with a fix landing

- **Given** `lib/util/date.rb` is outside every hot spot and was changed by one fix commit
- **When** rung 2 scans
- **Then** it is scanned in the second tier, and the header reads like `hot spots: <list>; then <n> files from co-change pairs and fix landings`

### Requirement: Rung 1 restricts where candidates are looked for, never the measurement

The system SHALL resolve a direction against `git ls-files` or the code's own names, SHALL still take Step 2's measurements over the whole repo, and SHALL look for candidates only within the direction.

#### Scenario: A direction inside a single package

- **Given** the user runs `/improve-architecture src/payments`
- **When** hot spots are computed
- **Then** they are computed over the whole repo, and candidates are raised only within `src/payments`

### Requirement: An ambiguous or unmatched direction asks once, with a defined unattended outcome

The system SHALL, when a direction matches several places, ask "**`<direction>` matches `<list>`. Scan one of them, several, or all?**" and with no answer scan all of them, noting the ambiguity and what was scanned in the header; and SHALL, when it matches nothing, ask "**`<direction>` matches no path or name in this repo. Name a path, or fall back to the commit-history hot spots?**" and with no answer fall to rung 2, recording in the header that the direction matched nothing.

#### Scenario: Unattended, ambiguous direction

- **Given** the direction `cache` matches `src/cache` and `tools/cache`, and nobody answers
- **When** the scope is resolved
- **Then** both are scanned and the header says the direction was ambiguous and lists both

#### Scenario: Unattended, no match

- **Given** the direction `ledger` matches nothing
- **When** nobody answers
- **Then** the pass uses rung 2 and the header records that the direction matched nothing

### Requirement: Rung 3 scans the whole tree breadth-first and reports the scatter

The system SHALL, under rung 3, put the measurement in the header (`most-touched: N touches, median M — no hot spot`), scan every top-level area breadth-first, list the areas covered, and never present an arbitrarily chosen area as a hot spot.

#### Scenario: Scattered history

- **Given** Step 2 reported the bar degenerate
- **When** the scan runs
- **Then** every top-level area is scanned and listed, and no area is called a hot spot

### Requirement: Raise candidates in five classes by their observable signal

The system SHALL raise a candidate only in one of five classes, each from its signal: (1) concept scatter from a co-change set the class table assigns to class 1; (2) shallow interface from the deletion test's signal or an interface with one adapter (a base class with exactly one subclass counts as one); (3) tested in isolation, broken at the call — a function with its own tests while fix landings in its area change its callers; (4) leaky seam from a co-change set assigned `4, co-change`, or one module reading another's internals or storage shape outside any co-change set (`4, internals`); (5) untestable through its interface by interface-design item 5's signal. It SHALL leave out a smell from the refactoring inventory that fits none of these classes, and SHALL not treat *Design it twice* as a class.

#### Scenario: A smell that fits no class

- **Given** a long parameter list appears in a scanned file
- **When** candidates are raised
- **Then** it is not raised, because no class holds it

#### Scenario: Tests pass, callers keep getting fixed

- **Given** `normalize()` has its own tests and three fix landings changed its callers but not `normalize()`
- **When** candidates are raised
- **Then** a class 3 candidate is raised on `normalize()`

### Requirement: Classify each co-change set exactly once by module boundary, size and internal references

The system SHALL build co-change sets by following pairs transitively, SHALL collect each set's internal references (imports, calls, names, storage shape or configuration keys among its files), and SHALL classify each set once: inside one module with four or more files as class 1; inside one module with fewer than four as not a candidate; crossing a module boundary with an internal reference as `4, co-change`; crossing with none and four or more files as class 1; crossing with none and fewer than four as not a candidate. A set raised as `4, co-change` SHALL never be raised again as `4, internals`.

#### Scenario: Three files across modules, no references

- **Given** a co-change set of three files in two packages that do not reference each other
- **When** it is classified
- **Then** it is not a candidate (duplicated code is not this pass's finding)

#### Scenario: Two files across modules with an import

- **Given** a co-change set of two files in different packages where one imports the other
- **When** it is classified
- **Then** it is a `4, co-change` candidate and is not also raised as `4, internals`

### Requirement: An unestablishable reference counts as none and makes the candidate tentative

The system SHALL count a reference it cannot establish either way (dependency injection, reflection) as none, mark the set's internal references incomplete so the candidate's strength is `tentative`, and SHALL move the set to class 4 with a new key on a later run that does establish the reference.

#### Scenario: Wiring through a container

- **Given** four files across two modules co-change and connect only through a DI container
- **When** the set is classified
- **Then** it is class 1, its internal references are incomplete, and its strength is `tentative`

### Requirement: A module is the build's unit above a file, else the directory

The system SHALL take a module to be the unit the build declares above a single file (project, package, crate), or the directory where the build declares none, never a single file, and SHALL use this definition for class 4's boundary and the report's frames.

#### Scenario: Python files in one package

- **Given** two `.py` files in one package co-change
- **When** module membership is decided
- **Then** they are in one module, not two

### Requirement: Every candidate collects its callers and co-change partners, marking incomplete sets

The system SHALL collect for every candidate its callers (files that call or import what the candidate is about) and its co-change partners (for a co-change set, every other file of the set; otherwise files paired with its main file), plus internal references for a co-change set, and SHALL record a set it cannot build in full (dynamic dispatch, reflection, users outside the repo) as incomplete.

#### Scenario: Public library entry point

- **Given** a candidate type is part of a published library API
- **When** its callers are collected
- **Then** the callers set is recorded as incomplete

### Requirement: Every candidate has a stable key

The system SHALL key each candidate `<n>:<path>` — class number and main file — where a co-change set's main file is its first path in `git ls-files` order, and SHALL append `#<member>` whenever the gate judged an element smaller than the whole file: the element's qualified name inside the file joined by `::`, generic arguments dropped, overloads counted as one. Item 4 candidates SHALL be keyed on the abstraction's own file, class 3 on the function, class 5 on the element whose behaviour cannot be seen; co-change and `4, internals` candidates, and a whole module with nothing smaller to name, SHALL carry no suffix. The key SHALL depend only on the judged element; a `partial` type takes its first file in `git ls-files` order; two same-class candidates on one file, neither about one member, are one candidate; a rename or a narrowing from file to member yields a new key.

#### Scenario: Nested type method

- **Given** the deletion test judged method `Save` of nested type `Inner` inside `Outer<T>` in `src/store.cs`
- **When** the key is written
- **Then** it is `2:src/store.cs#Outer::Inner::Save`

#### Scenario: Callback on one subscriber

- **Given** an item 4 candidate on the `OnError` event owned by `Client`, consumed in `src/ui.ts`
- **When** the key is written
- **Then** it uses `Client`'s file and `#Client::OnError`, never `src/ui.ts`

#### Scenario: Unrelated type added

- **Given** a keyed candidate `2:src/a.cs#Parser`
- **When** an unrelated type is added to `src/a.cs`
- **Then** the key is unchanged

### Requirement: Keys read back by a fixed rule

The system SHALL read a key back with the class running to the first `:`, the member being the text after the last `#` only when it holds no `/` and no `.` (otherwise the `#` belongs to the path), and, inside an entry, the key ending at the first ` — `.

#### Scenario: A hash in a directory name

- **Given** the key `1:src/C#/util.cs`
- **When** it is read back
- **Then** it has no member, because `/util.cs` holds a `/` and a `.`

### Requirement: Exactly one gate per candidate, chosen by the signal that raised it

The system SHALL state for every candidate which test judged it and its answer, applying exactly one gate: the deletion test (line `Deletion test: <outcome> — callers checked: <paths>`) for a class 2 candidate raised on the deletion test's signal; interface-design item 4 (line `Item 4: <n> implementation(s) — <result>`) for a class 2 candidate raised on one adapter; and `Gate: not a shallowness claim — <class>` for classes 1, 3, 4 and 5.

#### Scenario: Class 4 candidate

- **Given** a `4, co-change` candidate
- **When** it is gated
- **Then** its gate line is `Gate: not a shallowness claim — 4, co-change`, or `Gate: signal fails — …` if its signal fails

### Requirement: Deletion test outcomes map to a fixed result

The system SHALL map the deletion test's outcomes as: concentrates → candidate, delete or merge; merely moves with two or more callers and interface still shallow → candidate, deepen; merely moves with two or more callers and interface not shallow → rejected; merely moves with one caller → decided by the *Speculative generality* row, named (candidate to inline when no second caller is in sight, otherwise rejected); a data shape → rejected as a data shape. For an outcome the deletion-test section names that this table lacks, it SHALL report `Deletion test: undecided — <outcome>` and leave the candidate undecided.

#### Scenario: One caller, merely moves

- **Given** a wrapper with one caller whose inlining leaves the total logic unchanged and no second caller is in sight
- **When** the deletion test runs
- **Then** it is a candidate to inline, and the gate line names *Speculative generality*

#### Scenario: A DTO

- **Given** a candidate that only mirrors a config section
- **When** the deletion test runs
- **Then** it is rejected as a data shape

### Requirement: A non-shallowness signal may be killed only with named evidence

The system SHALL, when a closer look kills a class 1, 3, 4 or 5 signal (a co-change commit undone leaving fewer than 5 shared commits; files serving separate use cases; unrelated caller fixes; behaviour visible through the interface after all), write `Gate: signal fails — <class> — <the commit or paths that show it>` — with class 4 naming `4, co-change` or `4, internals` — and reject the candidate with its record; it SHALL never kill a signal without naming that evidence.

#### Scenario: Reverted co-change

- **Given** a co-change pair whose shared commits drop to 4 once a reverted commit is discounted
- **When** the gate runs
- **Then** the candidate is rejected with `Gate: signal fails — 1 — <the revert hash>`

### Requirement: Rejections are recorded in intake's re-checkable shape, never in code comments

The system SHALL record each rejection as `- <key> — <reason> (callers: <paths>; at <commit>)`, where `<reason>` is the gate line verbatim, `<commit>` is `git rev-parse --short HEAD` when the test ran, and the `callers:` slot holds the whole set the verdict turned on — callers for the deletion test, class 3, class 5 and `4, internals`; implementations for item 4; co-change partners for class 1 and `4, co-change` — separated by `, `, ending `, incomplete` for an incomplete set, and `none` when empty. It SHALL never record a rejection in a code comment.

#### Scenario: Item 4 rejection

- **Given** an item 4 rejection on `src/repo.ts#IRepo` with implementations `src/sql.ts` and `test/fakeRepo.ts`
- **When** it is recorded
- **Then** the line's `callers:` slot reads `src/sql.ts, test/fakeRepo.ts`

### Requirement: A recorded rejection suppresses the candidate, never the re-check

The system SHALL re-check every rejection Step 1 read except `held by ADR` entries: report `rejected file gone: <key> (since <commit>)` when the key's path is no longer listed; report `rejected member gone: <key> (since <commit>)` when the member is gone; otherwise run `git log <commit>..HEAD --format=%h -- <path> <callers>` (path alone for `callers: none`), rebuild a callers or implementations slot (never a co-change slot) and compare it; report `previously rejected, unchanged since <commit>` without re-running the gate when the log is empty and every rebuilt set matches; and re-run the gate the reason names and record the new result when the log prints anything, a set differs, or `<commit>` cannot be resolved. It SHALL never edit the earlier run's record.

#### Scenario: Untouched rejection

- **Given** a dropped entry at commit `a1b2c3d` whose path and callers have no commits since and whose rebuilt callers match
- **When** it is re-checked
- **Then** it is reported `previously rejected, unchanged since a1b2c3d` and the gate is not re-run

#### Scenario: A new caller appeared

- **Given** a deletion-test rejection whose rebuilt caller set now has one more file
- **When** it is re-checked
- **Then** the deletion test is re-run and the new result recorded

#### Scenario: History rewritten

- **Given** `<commit>` in an entry no longer resolves
- **When** it is re-checked
- **Then** the gate is re-run

### Requirement: A move contradicting a decision record is surfaced only on real friction

The system SHALL treat a move as contradicting a record when it would reinstate a *Rejected alternative* or undo its *Decision* in the area the move names, including moves set aside before becoming candidates and every `held by ADR` entry read in Step 1 whatever the scope. With friction — the area is a hot spot or fix landings cluster there, with commits cited (only fix landings under rung 3) — it SHALL surface the candidate marked `contradicts ADR NNNN — <title>` and recommend reopening the record through `domain`, never proposing the code change alone; without friction it SHALL list it as rejected `<key> — held by ADR NNNN — <title> (at <commit>)`, keyed by the element the move would change.

#### Scenario: Held move, quiet area

- **Given** a merge that ADR 0004 rejected, in an area with no hot spot and no fix landings
- **When** decision records are applied
- **Then** it is listed as `<key> — held by ADR 0004 — <title> (at <commit>)` and not proposed

#### Scenario: Held move, area becomes hot

- **Given** an earlier run recorded a move as held by ADR 0004, and the area is now a hot spot
- **When** this run recomputes friction
- **Then** the candidate is surfaced marked `contradicts ADR 0004 — <title>` with the hot-spot commits cited

### Requirement: Findings are filed through intake into a new epic before the report is written

The system SHALL file findings through `/tasks intake` — never a batch of `/tasks new` — before writing the report, with scope `architecture — <rung>` and `--source "improve-architecture <short HEAD> <date> — report: <the report's path>"` (the temp path known in advance), always into a new epic and never with `--epic`, whatever the run's size, and SHALL ask nothing before filing.

#### Scenario: A one-candidate run

- **Given** a run with one candidate and no rejections
- **When** findings are filed
- **Then** a new `kind: review-intake` epic is created through intake, rather than a spawned task

### Requirement: Each filed task carries its candidate key and the six parts, with merge-time criteria

The system SHALL file each candidate as one finding (intake mints `IA-<n>` and groups tasks), SHALL write into each filed task's `## Context`, per finding, `Candidate key: <key> — IA-<n>` exactly and the six parts with the before/after in text form, SHALL do the same into an open task intake links a finding to as a duplicate, and SHALL write acceptance criteria checkable when the task is merged — never one only a later run's history can answer, and never an escape clause.

#### Scenario: Intake links a duplicate

- **Given** intake links IA-2 to open TASK-150 as a duplicate
- **When** the finding is filed
- **Then** TASK-150's Context gains `Candidate key: <key> — IA-2` and the six parts

#### Scenario: Forbidden criterion

- **Given** a class 1 candidate
- **When** acceptance criteria are written
- **Then** they name the structural fact (e.g. the copy is gone and readers point at the owner), not "the co-change count drops"

### Requirement: Special candidates are filed by their marking

The system SHALL file a `recurs after TASK-NNN` candidate fresh with its Context saying it is a regression; SHALL not file `already filed` or `declined` candidates; SHALL file an undecided candidate as a candidate at `tentative`; and SHALL file a `contradicts ADR NNNN` candidate with "reopen ADR NNNN through [[domain]]; if the record stands, cancel this task citing it" as its first criterion.

#### Scenario: Contradicts a record

- **Given** a candidate marked `contradicts ADR 0007 — <title>`
- **When** it is filed
- **Then** its first acceptance criterion tells the developer to reopen ADR 0007 through domain, or cancel citing it

### Requirement: Every finding is a suggestion, themed by class

The system SHALL file every finding with severity `suggestion`, and SHALL set its theme by class — classes 1 and 2 `reuse-dead-code`, classes 3 and 4 `correctness-invariants`, class 5 `docs-i18n-coverage` — placing a task that holds findings of two themes under the story of the theme first in intake's ladder.

#### Scenario: Mixed task

- **Given** one task groups a class 2 and a class 4 finding
- **When** it is filed
- **Then** it goes under the `correctness-invariants` story

### Requirement: The dropped list carries every standing rejection forward

The system SHALL write into the new epic's dropped list, verbatim, this run's rejections, the `held by ADR` lines from Step 6, and every `previously rejected, unchanged` entry copied as it stands; SHALL not copy a gone entry but name it in the epic's area of concern as `not carried forward: <key> — rejected file gone (since <commit>)` or `rejected member gone`; and SHALL write the list even when the run has no candidate.

#### Scenario: A rejected file was deleted

- **Given** the earlier dropped list holds a rejection on `src/old.js`, which is no longer tracked
- **When** this run files
- **Then** the new dropped list omits it and the area of concern says `not carried forward: <key> — rejected file gone (since <commit>)`

### Requirement: With no task tree, nothing is created and the report says how to file later

The system SHALL, when no task tree exists, create nothing and set the report's records line to `not filed — no task tree; run /tasks init, then /tasks intake --source <the report's path>`.

#### Scenario: Fresh repository

- **Given** the repo has no task tree
- **When** Step 7 runs
- **Then** no tree or epic is created and the records line gives the init-then-intake command

### Requirement: The report is always written to a temp file outside the repo, and published privately when possible

The system SHALL always write the report first as one self-contained HTML file (inline CSS and SVG, nothing fetched) to `<tmp>/improve-architecture-<repo>-<short HEAD>.html`, where `<tmp>` is the runtime's scratch directory else `$TMPDIR`, `%TEMP%` or `/tmp`, never inside the repo; SHALL publish it privately when the session's tools include one that publishes an HTML page visible only to the user, deciding from the tools present and never widening visibility; SHALL treat a surface that cannot publish privately as absent; SHALL, with no such tool or a failed publish, print the temp file's absolute path and the reason (`no publishing surface` or `publish failed: <error>`); and SHALL ask nothing before publishing.

#### Scenario: Runtime without a publishing tool

- **Given** the session has no page-publishing tool
- **When** the report is delivered
- **Then** the temp file is the report and stdout prints its absolute path with `no publishing surface`

#### Scenario: Publish errors

- **Given** the publishing tool returns an error
- **When** the report is delivered
- **Then** stdout prints the temp path with `publish failed: <error>`

### Requirement: Every candidate fills six parts, none omitted

The system SHALL present every candidate with Files (main file first, key, `recurs after` when found), Problem (class and signal evidence), Solution (the move, the gate line verbatim, and any `contradicts ADR` marking with reopening as the first step), Benefits, Before/after and Strength, writing `none — <why>` for an empty part rather than leaving it out.

#### Scenario: No decision record applies

- **Given** a candidate that contradicts no record
- **When** its Solution is written
- **Then** it holds the move and gate line, and every other part is still present

### Requirement: Benefits are leverage and locality only, never combined

The system SHALL state benefits only as a leverage line (callers that stop carrying a pass-through, workaround or copy, counted and named) and a locality line (files touched per change before and after, and callers left untouched), side by side and never combined into a score, writing `not measured — <why>` for a figure it could not count and never an adjective such as "cleaner".

#### Scenario: Uncountable callers

- **Given** a candidate whose callers set is incomplete
- **When** benefits are written
- **Then** an uncountable figure reads `not measured — <why>`

### Requirement: The before/after visual shows a fixed content in two matching panels

The system SHALL draw two panels on the same layout: a box per file (callers outside the list in one `callers (n)` box, named when three or fewer), solid arrows for calls and imports, dashed lines for co-change pairs labelled with shared-commit counts, a frame per module; the after panel SHALL draw the move with changed boxes and edges highlighted and the rest grey, at most twelve boxes a panel (more fold into `+n more`), and a text form under each panel (`A → B; A ~ B (7 commits)`).

#### Scenario: Many callers

- **Given** a candidate with 15 boxes worth of files
- **When** the visual is drawn
- **Then** each panel shows at most twelve boxes with the rest folded into `+n more`, and a text form under each panel

### Requirement: Strength is confidence, chosen by first matching row, and never priority

The system SHALL assign `tentative` when the gate is undecided or a path set is incomplete; otherwise `strong` when history corroborates the candidate with evidence other than the signal that raised it (fix landings or `recurs after` for co-change; co-change or `recurs after` for fix landings; any of the three in its own files for the rest); otherwise `moderate`. Nothing else — hot-spot rank, payoff, effort, decision records, scope properties — SHALL move it, and candidates SHALL be listed by rung 2 tier then key, never by strength.

#### Scenario: Co-change with fix landings

- **Given** a class 1 candidate raised on co-change whose files also have fix landings, with complete path sets
- **When** strength is set
- **Then** it is `strong`

#### Scenario: Co-change alone

- **Given** a class 1 candidate with no fix landings and no `recurs after`
- **When** strength is set
- **Then** it is `moderate`

### Requirement: The page ends with header and four listing sections, each printed even when empty

The system SHALL print, each as a plain table and `(none)` when empty: the header (scope rung and coverage, measurement, `bar degenerate`, renames, what was already settled, any unattributed intake epic, and in bold on its own line the records line `filed into EPIC-NNN` or `not filed yet — this report is the only copy of the rejections below`); Rejected, with each record line verbatim; Previously rejected, unchanged; Rejections gone; and Already filed (`<key> — TASK-NNN` or `<key> — declined: TASK-NNN`).

#### Scenario: Nothing previously rejected

- **Given** a first run
- **When** the page is written
- **Then** the Previously rejected, Rejections gone and Already filed sections each print `(none)`

### Requirement: Stdout repeats the whole report in a fixed shape

The system SHALL print to stdout, however the page was delivered, the scope line, the `already settled` line, the `records:` line, the Candidates (class, main file, key, strength with its evidence, `recurs after`, evidence, gate line, `contradicts ADR`), Rejected, Previously rejected, unchanged, Rejections gone, Already filed, and `report: <link> | <path> (<reason>)`, every section printing `(none)` when empty and the rejection sections in full.

#### Scenario: Published page

- **Given** the page was published and a link returned
- **When** stdout is printed
- **Then** every rejection is still printed in full and the last line is `report: <link>`

### Requirement: The pass reviews shape only

The system SHALL not judge correctness, lint against the rulebook, reopen a decision record, change code, or drain the tasks it files.

#### Scenario: A correctness bug is noticed

- **Given** the scan passes an off-by-one error
- **When** candidates are raised
- **Then** it is not raised as a finding of this pass
