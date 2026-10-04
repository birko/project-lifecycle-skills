---
area: change-review
generated-at: adc4c27f8733e01ca655b4ec26dfe0a68e190b0f
generated-on: 2026-10-04
sources:
  - skills-pi/code-review/SKILL.md
  - skills-pi/review/SKILL.md
  - skills-pi/security-review/SKILL.md
  - skills/review-comments/SKILL.md
  - skills/verify-conventions/SKILL.md
  - skills/verify-intent/SKILL.md
shaped-by: [FEATURE-002]
shaped-by-derived: true
shaped-by-unresolved: 7
---

# The gate on a change — your own rules, the task's criteria, correctness, security, and comments

## Purpose

Before a change is accepted, it is judged along several independent axes, each answering a different question about the same diff: does it follow the rules this project wrote down for itself (rules axis), did it build what the task and the agreed decisions asked for and nothing else (intent axis), is it correct (correctness axis), is it safe (security axis, only when the diff touches a security surface), and does any comment in it hold content that already lives somewhere else (comment axis). A merge gate runs these together on one diff, and each axis reports its own verdict with its own severities; nothing is merged into one ranked list, because a convention warning placed above an unbuilt requirement reads as the bigger problem. The rules, intent and comment axes are tech-agnostic skills that read what the project itself recorded. The correctness, PR-level and security reviewers are fallbacks shipped only for the pi runtime, so a gate there still resolves a reviewer instead of silently skipping it; in Claude Code the runtime is expected to provide those reviewers itself. Anyone who relies on a task's `done` meaning "checked against our rules, its own criteria, and for bugs" depends on this capability.

## Requirements

### Requirement: Axes report side by side and are never merged

The system SHALL report each review axis as its own verdict with its own severity ordering, and SHALL NOT merge or rerank findings from different axes into one list; each axis disclaims the questions the others answer.

#### Scenario: A gate runs the rules, intent and correctness axes on one diff

- **Given** a diff with one rules-axis ⚠ warning and one intent-axis Missing finding
- **When** the axes are run together at a gate
- **Then** each axis prints its own report and verdict, and the warning is not sorted above or below the Missing finding

#### Scenario: Clean conventional correct code that builds the wrong thing

- **Given** a change that passes the rules axis and the correctness axis but implements something no criterion asked for
- **When** the intent axis runs
- **Then** it reports the scope creep on its own, regardless of the other two verdicts

### Requirement: The axes are advisory and decide nothing about merging

The system SHALL treat rules-, intent- and comment-axis findings as advisory. The rules axis SHALL NOT auto-fix or block a commit by itself. The intent axis SHALL NOT fix code, rewrite a task's criteria, or decide whether the change lands. The comment axis SHALL edit nothing until a human confirms a finding, and after confirmation SHALL delete a comment whose content it found at the named destination.

#### Scenario: The intent axis finds a missing criterion

- **Given** a diff that leaves acceptance criterion 4 unbuilt
- **When** the intent axis reports
- **Then** it names the Missing finding but neither edits the code nor rewords criterion 4 to fit what was built

#### Scenario: Hard enforcement is wanted for the rules axis

- **Given** a team that wants the rules axis to block commits
- **When** they consult the skill
- **Then** it directs them to wire a pre-commit hook rather than blocking anything itself

### Requirement: Every axis resolves the diff the same way

The system SHALL, in each axis that reviews a diff, prefer the staged diff, fall back to the working tree, use a branch or PR range only when one is named or asked for, and ask which files to check when the project is not git-tracked.

#### Scenario: Nothing is staged

- **Given** a repo with working-tree changes and an empty index
- **When** the rules, intent or comment axis runs with no target
- **Then** it reviews `git diff` of the working tree

#### Scenario: Not a git repository

- **Given** a folder that is not git-tracked
- **When** any of these axes runs
- **Then** it asks the user which files to check

### Requirement: Rules axis — the rulebook is the project's own guide, found by content

The system SHALL, on every invocation of the rules axis, re-read the project's own agent guide (`CLAUDE.md`, or `AGENTS.md` through the `@import` bridge) and locate the rulebook by working down a ladder — a `## Conventions` section; then a heading that plainly names rules in the guide's own language; then any section carrying sustained normative content; then every normative statement in the whole guide — stopping at the first hit, and SHALL extract the rules into a working checklist grouped the way the guide groups them, dropping no rule for failing to fit a subsection.

#### Scenario: Rules under a Slovak heading

- **Given** a guide with no `## Conventions` but a `## Pravidlá` section full of rules
- **When** the rules axis runs
- **Then** it uses `## Pravidlá` as the rulebook at rung 2 and lints against it

#### Scenario: Rules woven through the guide

- **Given** a guide with no rule-naming headings, whose "never" and "always" statements are scattered across sections
- **When** the rules axis runs
- **Then** it lints against all normative statements in the whole guide (rung 4)

### Requirement: Rules axis — "no conventions recorded" only when the guide has no normative content

The system SHALL report that a project has recorded no conventions only when the whole ladder found no normative content; it SHALL then say so plainly, point at the `new-project` seed's `## Conventions` block, and run the smell baseline, and SHALL never suggest restructuring a working guide to match the seed.

#### Scenario: A rich guide under unfamiliar headings

- **Given** a long guide with a dozen rule sections, none named "Conventions"
- **When** the rules axis runs
- **Then** it does not report "no conventions recorded"

#### Scenario: A guide with no rules at all

- **Given** a guide that is entirely description, with no normative statement
- **When** the rules axis runs
- **Then** it states that no conventions are recorded, points at the seed, and runs the smell baseline

### Requirement: Rules axis — the report header names the rulebook read and the extension status

The system SHALL open every rules-axis report, clean or not, with a header naming the guide file, the headings treated as normative in the guide's own language, the ladder rung that matched, the project extension's status, and any files excluded as generated with the reason for each.

#### Scenario: A clean pass

- **Given** a diff that violates no rule
- **When** the rules axis reports
- **Then** the output starts with the `Rulebook:` line and a `Project extension:` line, followed by the excluded files, before the `✅ Change follows the project's documented conventions.` verdict

### Requirement: Rules axis — a project-local extension is discovered and run, never shadowed

The system SHALL glob the project for `.claude/skills/verify-*conventions*/SKILL.md` (excluding its own directory, and also honouring any path the guide names), and SHALL then: when none is found, report `project extension: none found`; when one or more are found, run its own generic steps first, then execute each extension's checks while telling it the generic pass already ran, and name each extension as run on the header; and when an extension is found but not run for any reason — unreadable, errored, or chosen not to — report it as a 🛑 blocker, never a clean pass.

#### Scenario: An extension is present

- **Given** a repo with `.claude/skills/verify-birko-conventions/SKILL.md`
- **When** the rules axis runs
- **Then** it runs the generic pass, then the extension's checks, and its header reads `project extension: .claude/skills/verify-birko-conventions/SKILL.md (ran)`

#### Scenario: The extension errors

- **Given** a found extension that cannot be read
- **When** the rules axis reports
- **Then** it emits `🛑 project extension found but NOT run — <path>. The stack-specific checks did not happen.`

#### Scenario: A project-local skill named exactly verify-conventions

- **Given** a repo that ships its own `.claude/skills/verify-conventions/` while the generic skill is installed at user level
- **When** the skill is resolved by name
- **Then** the user-level skill wins; the project copy never runs by name and is reachable only through the step-0 glob

### Requirement: Rules axis — generated, vendored and minified files are dropped by declaration first

The system SHALL drop generated, vendored and minified files from the rules axis's diff, deciding by `.gitattributes` `linguist-generated`/`linguist-vendored` first, then paths the guide names as build output or vendor, then heuristics (`.map`, lockfiles, known vendor directories, minified shape); SHALL lint a file it cannot classify and say so; SHALL name a heuristic-based exclusion as such; SHALL NOT use `docs/specs/.map.yml`'s `ignore:` list as a generated-file oracle; and SHALL say `nothing to lint` with the exclusion list when every changed file is generated.

#### Scenario: A small generated service worker

- **Given** a 128-line generated `sw.js` with no `.gitattributes` declaration and no guide mention
- **When** the rules axis classifies files
- **Then** it lints `sw.js`, because no signal identifies it as generated

#### Scenario: The diff is entirely a bundle

- **Given** a diff that changes only `app.js` and `app.js.map`, both minified
- **When** the rules axis runs
- **Then** it reports `nothing to lint — all 2 changed files are generated output` with the reason for each

#### Scenario: Specs ignore list covers tests

- **Given** `.map.yml` declares `tests/**` under `ignore:`
- **When** the diff changes a test file
- **Then** the test file is still linted

### Requirement: Rules axis — each violation quotes the rule it breaks

The system SHALL check each changed file against each rule whose domain matches the file's kind or path, and SHALL report every violation with a clickable `path:line`, the quoted guide line it comes from, and a one-line suggested fix, grouped as 🛑 (hard, unambiguous rule), ⚠ (likely violation needing judgement) and 💡 (register-on-introduce gaps, architecture-doc drift, soft style rules).

#### Scenario: A handler queries the database directly

- **Given** a guide rule "Handlers never touch the DB directly — go through a repository" and a diff adding `db.query(...)` in `src/api/orders.ts:54`
- **When** the rules axis reports
- **Then** it emits a 🛑 Blocker at `src/api/orders.ts:54` quoting that rule, with a one-line fix

### Requirement: Rules axis — a new cross-cutting pattern must be recorded in the same change

The system SHALL flag a diff that establishes a new cross-cutting pattern — a new framework or major dependency, a UI pattern not in the rules, a new architectural layer or module shape, a new naming or testing convention — without updating `CLAUDE.md` § Conventions (and `## Architecture` when structure changed) in the same change, with the message *"New pattern introduced (`<what>`) but not recorded in CLAUDE.md § Conventions — add it so the next task follows it."*

#### Scenario: A new state-management library

- **Given** a diff adding `zustand` to `package.json` while the guide lists only Redux, and no guide change
- **When** the rules axis runs
- **Then** it reports a 💡 register-on-introduce finding naming `zustand`

### Requirement: Rules axis — architecture drift is flagged

The system SHALL flag a change that alters structure (a new module, engine, protocol or dependency direction) while `## Architecture` still describes the old shape.

#### Scenario: A new module with a stale architecture section

- **Given** a diff introducing a new `billing/` engine and an `## Architecture` section that does not mention it
- **When** the rules axis runs
- **Then** it reports architecture drift (in the 💡 group)

### Requirement: Rules axis — the smell baseline is a labelled floor that the repo overrides

The system SHALL read the code-smell inventory from the `tdd` skill's refactor-candidates file rather than a copy, SHALL run it after the rulebook sweep with its findings separated below the rule findings, SHALL prefix each with `smell:` at ⚠ or 💡 and never 🛑, SHALL suppress any smell that conflicts with a documented rule outright, and SHALL skip anything the repo's linter, formatter, compiler or analyzer already reports.

#### Scenario: Duplication is the documented design

- **Given** a guide stating "handlers construct their own DTOs inline — no mapper layer" and a diff duplicating DTO construction across handlers
- **When** the smell baseline runs
- **Then** no duplicated-code smell is reported

#### Scenario: Repeated switches in a repo with no rules

- **Given** a repo with no recorded conventions and the same `match plan_kind` chain in three places
- **When** the rules axis runs
- **Then** it reports `⚠ smell: repeated switches` with the three locations and labels it a judgement call

#### Scenario: An analyzer already enforces it

- **Given** an analyzer configured to error on unused parameters
- **When** the smell baseline sees an unused parameter
- **Then** it does not report it

### Requirement: Intent axis — the intent sources and their precedence

The system SHALL take intent from a named task's `## Acceptance criteria`; when that task carries `feature: FEATURE-NNN`, also from the `approved` and `changed` rows of that feature's decision ledger, read through the `roadmap` skill's Cross-tree pass; with no argument, from the in-progress task's criteria, naming the task picked; and with no argument and no task in flight, by asking the user in one line what the change was meant to do.

#### Scenario: A task linked to a feature

- **Given** `/verify-intent TASK-046` where TASK-046 carries `feature: FEATURE-012`
- **When** the intent axis resolves its sources
- **Then** it reads TASK-046's criteria and FEATURE-012's `approved` and `changed` decisions

#### Scenario: No task anywhere

- **Given** no task id given and no task in progress
- **When** the intent axis runs
- **Then** it asks the user, in one line, what the change was meant to do

### Requirement: Intent axis — a decision outranks a task criterion

The system SHALL treat an `approved` decision as outranking a task criterion, and SHALL report a diff that satisfies its task while contradicting an `approved` decision as a finding against the decision, quoting both.

#### Scenario: Criteria drifted from the ledger

- **Given** a diff that meets TASK-050's criterion but contradicts FEATURE-012 D3 (`approved`)
- **When** the intent axis reports
- **Then** it raises a finding against D3, quoting D3 and the criterion

### Requirement: Intent axis — decided-against and undecided rows are surfaced

The system SHALL report a diff implementing a `removed` or `deferred` decision as scope creep of the worst kind, quoting that row's rationale, and SHALL surface a diff implementing a `proposed` decision as a decision taken by whoever wrote the code.

#### Scenario: Implementing a removed decision

- **Given** FEATURE-012 D7 is `removed` with rationale "replaced by D9"
- **When** the diff implements D7
- **Then** the intent axis reports scope creep quoting "replaced by D9"

### Requirement: Intent axis — specs are a baseline, not intent

The system SHALL NOT treat `docs/specs/` as an intent source; it SHALL resolve which spec areas cover the changed files from the specs map's globs, and for each spec requirement the diff contradicts, SHALL report scope creep (quoting the requirement and the contradicting `file:line`) when no decision or criterion asked for the change, and treat it as a stale spec needing `/specs regen` — not a finding — when one did.

#### Scenario: An unasked behavioural change

- **Given** a diff that contradicts a requirement in `docs/specs/auth-session.md` and no criterion or decision asks for it
- **When** the intent axis runs
- **Then** it reports scope creep quoting the spec requirement and the `file:line`

#### Scenario: A requested behavioural change

- **Given** the same contradiction, but the task's criterion asks for exactly that change
- **When** the intent axis runs
- **Then** it raises no finding and notes that the spec is now stale

### Requirement: Intent axis — the header names sources read and sources absent

The system SHALL lead every intent-axis report, including a clean one, with the intent sources read (with counts), the baseline read with its coverage of the changed files, and the sources that were not there, never falling back silently.

#### Scenario: A task with no feature

- **Given** a task with `feature: null` and no `docs/features/`
- **When** the intent axis reports
- **Then** the header names the task's criteria as read and states that no decision ledger was read

#### Scenario: A clean pass

- **Given** a diff that implements every criterion and nothing else
- **When** the intent axis reports
- **Then** it prints `✅ The diff implements the stated intent, with nothing unasked-for.` with the same source lines

### Requirement: Intent axis — every criterion is judged against the diff, never its checkbox

The system SHALL ignore criterion checkboxes when classifying, so a ticked criterion with no corresponding change is Missing and a ticked one whose change diverges is Wrong, and SHALL append `— ticked, but the diff does not support it` to any finding whose criterion was ticked.

#### Scenario: A ticked but unbuilt criterion

- **Given** criterion 3 is ticked `[x]` and nothing in the diff implements it
- **When** the intent axis runs
- **Then** it reports Missing for criterion 3 with `— ticked, but the diff does not support it` appended

### Requirement: Intent axis — three classes plus an unverifiable outcome

The system SHALL walk the diff once mapping each hunk to the criterion it serves or to nothing, and SHALL classify an unmatched criterion (or one only partly built) as Missing, carrying the criterion verbatim and the `file:line` where the implementation should have gone; a matched but divergent criterion as Wrong, carrying the criterion, the `file:line` and the divergence; an unmatched hunk as Scope creep, carrying the `file:line`, what it does, and that no criterion covers it, with the usual resolution offered as `/tasks spawn` rather than a revert; and a criterion the diff cannot settle as *unverifiable from this diff*, with the reason, never counted as met or missing.

#### Scenario: A router wording change no criterion covers

- **Given** a hunk in `skills/tasks/SKILL.md:24` that no criterion asks for
- **When** the intent axis reports
- **Then** it lists Scope creep at that line and suggests `/tasks spawn`

#### Scenario: A criterion whose evidence is a drill

- **Given** criterion 8 "the lint run passes on a real repo"
- **When** the intent axis reports
- **Then** it lists criterion 8 under `Unverifiable from this diff`, saying the evidence is a drill

### Requirement: Correctness axis — the pi fallback provider

The system SHALL, in the pi runtime, provide the correctness axis as a fallback `code-review` skill that is never installed into Claude Code's skill root; it SHALL read the changed code in context (the task's criteria or feature decisions for intent, plus the surrounding file and callers), check each change for logic errors, unhandled edge cases, regressions callers depend on, breaking public-interface changes and missing tests for new surface, review only the delta, and never call a change fine without having read its callers.

#### Scenario: pi resolves the correctness reviewer

- **Given** a pi session where a gate references `code-review`
- **When** the reference is resolved
- **Then** the fallback stub runs its Steps instead of the gate silently skipping the pass

#### Scenario: Claude Code without a surfaced code-review skill

- **Given** a Claude Code session where `code-review` does not resolve
- **When** a gate calls for the correctness pass
- **Then** the stub states the caller's inline fallback does the pass, and the stub is not installed there

### Requirement: Correctness axis — every finding names a concrete failure

The system SHALL report a correctness finding only when it can name a concrete failure scenario (inputs or state leading to a wrong outcome), grouped as 🛑 Blocker (fix before merge), ⚠ Warning (should fix; waivable with a recorded reason) and 💡 Suggestion, each with a clickable `path:line`; missing tests for new surface SHALL be ⚠ unless security-sensitive; a clean pass SHALL print `✅ No correctness issues found.`

#### Scenario: A suspicion with no failing case

- **Given** a reviewer who suspects an off-by-one but cannot construct an input that fails
- **When** it reports
- **Then** the suspicion is not a finding

#### Scenario: New public function without tests

- **Given** a diff adding a public function with no test, not security-sensitive
- **When** the correctness axis reports
- **Then** it lists a ⚠ Warning, not a Blocker

### Requirement: Correctness axis — a security surface escalates to the security axis

The system SHALL, when the diff touches auth/session, data access, user input, file/path handling, crypto, secrets/config, new dependencies or exposed endpoints, say so and run the security axis on the same diff rather than a shallow security check inside the correctness pass.

#### Scenario: An auth change

- **Given** a diff editing the session-token validation
- **When** the correctness fallback reviews it
- **Then** it states the diff touches a security surface and runs `security-review` on the same diff

### Requirement: Correctness axis — fix and comment modes

The system SHALL apply confirmed findings to the working tree with `--fix` only when the user asks directly, and SHALL NOT do so at a gate invocation (`/tasks close`, `/feature review`), where it reports and routes; with `--comment` it SHALL post findings as inline PR comments instead of stdout.

#### Scenario: --fix at a gate

- **Given** `/tasks close` invokes the correctness pass
- **When** findings are produced
- **Then** they are reported and routed, not applied to the diff under judgement

### Requirement: Correctness and security axes — findings route by scope

The system SHALL route correctness and security findings by scope: in scope for the task being closed → fixed on its branch, a blocker holding the close; outside its acceptance criteria → `/tasks spawn` as its own task, never folded in, silently fixed or dropped; found at `/feature review` → a new or reopened task, the feature holding at `review`; a whole pass at project or module scale → `/tasks intake` as one `kind: review-intake` epic with stories by severity theme and one task per fix group, for `fix-next` to drain.

#### Scenario: An adjacent bug the diff exposed

- **Given** a correctness pass at close that finds a bug outside the task's criteria
- **When** the finding is routed
- **Then** it is spawned as its own task, and the task in hand's criteria are unchanged

#### Scenario: A codebase-wide security audit

- **Given** the security axis run over a whole module
- **When** its findings are filed
- **Then** they go through `/tasks intake` as one review-intake epic with `SEC-*` ids on each task

### Requirement: PR-level review — the pi fallback for the merge-time pass

The system SHALL, in the pi runtime, provide a fallback `review` skill never installed into Claude Code's skill root, which confirms a PR exists for the branch with a current head, reads the full PR diff, checks the aggregate for whether the combined changes satisfy the task's acceptance criteria and for cross-commit conflicts, merge artifacts, leftover debug or scaffolding, and integration issues between separately reviewed parts, without repeating per-hunk findings the working-tree reviews already made.

#### Scenario: Leftover scaffolding across commits

- **Given** a PR whose second commit leaves a debug print added by the first
- **When** the PR-level review runs
- **Then** it reports the leftover as an aggregate finding

### Requirement: PR-level review — findings post to the PR and merging needs the user

The system SHALL post PR-level findings as inline PR comments grouped 🛑/⚠/💡; on a clean result it SHALL approve and merge only with the user's go-ahead, on blockers it SHALL request changes and not merge, and it SHALL never merge, close or push without explicit user go-ahead.

#### Scenario: Clean PR, no go-ahead

- **Given** a PR with no findings and no user instruction to merge
- **When** the PR-level review finishes
- **Then** it approves the PR and does not merge it

### Requirement: Security axis — the pi fallback, conditional at the gate

The system SHALL, in the pi runtime, provide a fallback `security-review` skill never installed into Claude Code's skill root, fired per task at `/tasks close` only when the diff touches a security surface, per feature as an optional cumulative pass at `/feature review` Gate A, and on demand; it SHALL first identify security-relevant changes and, when there are none, say so and stop without inventing findings.

#### Scenario: No security surface

- **Given** a diff that only rewords documentation
- **When** the security axis runs on demand
- **Then** it reports that the change has no security surface and stops

### Requirement: Security axis — findings carry an attack path

The system SHALL check the applicable OWASP-Top-10-shaped basics stack-agnostically, SHALL report each finding with a clickable `path:line` and the concrete attack path (who sends what, from where, and what they gain), grading exploitable issues 🛑, real but not directly exploitable weaknesses ⚠, and theoretical-only or hardening items 💡; a new dependency with broad network, filesystem or process access SHALL be at least ⚠; a clean pass SHALL print `✅ No security issues found.`

#### Scenario: A theoretical-only concern

- **Given** a concern for which no concrete attack path can be named
- **When** the security axis reports
- **Then** it is listed as 💡

#### Scenario: A dependency spawning child processes

- **Given** a diff adding a dependency that spawns child processes
- **When** the security axis reports
- **Then** it lists at least a ⚠ for it

### Requirement: Security axis — never edits, and a security fix needs a regression test

The system SHALL offer no `--fix` mode on the security axis and never edit code from the pass, SHALL support `--comment` to post findings as inline PR comments, and SHALL hold that a fix to shipped security behaviour is not `done` without a regression test.

#### Scenario: Asked to fix during the pass

- **Given** a user running the security fallback on an exploitable injection
- **When** the pass completes
- **Then** it reports and routes the finding to a task; it does not patch the code

### Requirement: Comment axis — the rule is read from the project's guide, never carried

The system SHALL read the comment rule from the project's guide on every invocation by a ladder — the `comment-rule` start/end markers (rung 0), a heading naming comments in the guide's language (rung 1), normative content about comments under any heading (rung 2), or the universal floor read at runtime from `new-project`'s universal conventions template (rung 3) — SHALL name the rung on the report header, SHALL read destination names off the guide's own table (saying so when it has more rows than expected), and SHALL stop and report, composing nothing from memory, when neither a guide rule nor the template can be read.

#### Scenario: A reworded unmarked rule

- **Given** a guide carrying the comment rule reworded under `### Komentáre` with no markers
- **When** the comment axis runs
- **Then** it finds the rule at rung 1 rather than concluding there is no rule

#### Scenario: Template unreachable and no guide rule

- **Given** no comment rule in the guide and `new-project` not installed beside this skill
- **When** the comment axis runs
- **Then** it stops and reports, naming install drift, instead of applying a remembered rule

### Requirement: Comment axis — the universal floor is labelled, capped and overridden

The system SHALL, on the universal floor, prefix every finding `universal:` and cap it at ⚠, SHALL suppress outright any floor finding that conflicts with something the project decided, and SHALL recommend once, at the end, adding the § Comments block from the universal conventions template to the project's guide.

#### Scenario: Floor finding on a changelog comment

- **Given** a project with no comment rule and a diff adding a dated changelog comment
- **When** the comment axis reports
- **Then** the finding reads `universal:` at ⚠, never 🛑, and the report ends with the recommendation to record a rule

### Requirement: Comment axis — three scopes, and conflicting flags are refused by name

The system SHALL accept three scopes — the current diff (default), `PATH …` swept in full without consulting the diff, and `--all` over every tracked file — and SHALL refuse `--batch` without `--all` with *"`--batch` applies to `--all` only; any other scope prints in full"*, and `PATH` together with `--all` with *"`--all` is the whole repository; drop the paths, or drop `--all`"*, doing neither.

#### Scenario: --batch on a diff run

- **Given** `/review-comments --batch 2`
- **When** the comment axis starts
- **Then** it prints the refusal naming `--batch` and runs nothing

### Requirement: Comment axis — diff scope reaches whole blocks and attached comments

The system SHALL, in diff scope, bring a comment into scope when the diff adds or modifies any line of it, judging the whole block and its declaration, and SHALL also bring in an untouched comment immediately attached to a changed line — contiguously above it or trailing on it — but nothing further away.

#### Scenario: A comment made false by the change

- **Given** an untouched comment directly above a line the diff changes
- **When** the comment axis runs on the diff
- **Then** that comment is judged

#### Scenario: A stale block ten lines away

- **Given** a stale comment ten lines above the nearest changed line
- **When** the comment axis runs on the diff
- **Then** it is not in scope

### Requirement: Comment axis — path scope membership and its header

The system SHALL, in `PATH …` scope, take membership from `git ls-files`, expand a directory to its tracked files, report a directly named untracked path as `not tracked, not swept: <path>`, skip untracked files under an expanded directory silently, sweep a file named by its own path even if it looks generated (saying so), apply the generated/vendored exclusion to files reached by expansion, and print the header exactly as `Scope:        paths (diff not consulted) — <paths as given>: N of M tracked, S swept in full.` with the `N of M tracked` fragment always present, followed by one line per file not swept with its reason.

#### Scenario: A named untracked file

- **Given** `/review-comments src/mill.ts notes.txt` where `notes.txt` is untracked
- **When** the comment axis reports
- **Then** the header reads `… src/mill.ts, notes.txt: 1 of 2 tracked, 1 swept in full.` followed by `not tracked, not swept: notes.txt.`

#### Scenario: A generated file under a named directory

- **Given** `/review-comments src/` where `src/schema.gen.ts` is declared generated in `.gitattributes`
- **When** the comment axis reports
- **Then** the header reads `… src/: 2 of 2 tracked, 1 swept in full.` and names `src/schema.gen.ts` as excluded

### Requirement: Comment axis — comments identified by language, false positives avoided

The system SHALL identify comments by reading each file in its own language with no language table, SHALL exclude markers inside string literals, heredocs, template literals, regexes or URLs, shebangs, encoding lines, pragmas, linter directives and modelines, SHALL NOT sweep markup or config files, SHALL NOT report a span it cannot confirm is a comment, and SHALL exclude generated, vendored and minified files using the rules axis's ladder, naming the exclusions on the header.

#### Scenario: A hash inside a URL

- **Given** a string literal containing `https://example.com/#anchor`
- **When** the comment axis scans the file
- **Then** the `#anchor` is not treated as a comment

### Requirement: Comment axis — the destination test, severities, and what is never a finding

The system SHALL apply the project's destination test to each in-scope comment and report each finding quoting the comment text, its `path:line` and the destination row that caught it, at 🛑 when the rule names it as always a violation, ⚠ when its content appears to live at a destination, 💡 when it passes but a pointer would suffice, and **held** when its content exists nowhere else; a finding matching both 🛑 and ⚠ SHALL be 🛑; a comment's length, a one-line pointer, and a structurally required documentation tag SHALL never be findings; and every report SHALL list the comments deliberately left alone, a clean pass keeping its header with `✅ No comment carries content that lives somewhere else.`

#### Scenario: A long algorithm explanation

- **Given** a 31-line comment explaining a banker's-rounding edge case
- **When** the comment axis reports
- **Then** it is listed under the comments left alone, not as a finding

#### Scenario: A rationale essay that also has its ADR

- **Given** a rationale essay above a declaration whose reasoning is in `docs/adr/0004.md`
- **When** the comment axis reports
- **Then** the finding is 🛑, citing the decision-record destination

### Requirement: Comment axis — `--all` prints a census, then deterministic pages

The system SHALL, under `--all`, print a census of total findings, files affected and the always-violation/judgement split before any finding; page findings in batches of whole files capped at 20 findings (a single larger file is its own batch, noted in the census); order batches by finding density descending then path ascending, naming the key that ordered them and saying when ordering fell to path; ask nothing; and end with the resume command for the next batch.

#### Scenario: Every file has one finding

- **Given** an `--all` run where each affected file has exactly one finding
- **When** batches are ordered
- **Then** the report says density discriminated nothing and ordering fell to path

#### Scenario: Resuming after a cleared session

- **Given** an `--all` run that printed batch 1
- **When** it ends
- **Then** its last line is `/review-comments --all --batch 2`

### Requirement: Comment axis — nothing is deleted without confirmation, and an only copy is relocated before deletion

The system SHALL confirm with a human before editing anything; before a deletion SHALL verify the content is actually at the destination the finding named (version history being empty for an uncommitted line, and a guide section being read rather than trusted by name), citing where it lives when deleting; and when the content is an only copy SHALL choose a destination by its kind (a finding → a task via `/tasks spawn`; a rationale → a decision record; a standing rule → the project's guide, never the shipped template; reference material → a `docs/` page; unclear → held), ask the verbatim question *"`<path>:<lines>` — this content exists nowhere else … File it as a <task | decision record | guide rule | docs page> and leave a pointer, or keep the comment as it is?"*, and only after an answer relocate, leave a one-line pointer naming the destination by id or path, and then delete.

#### Scenario: Only copy in a scoped run, no answer

- **Given** a path-scoped run finding a changelog comment on an uncommitted line
- **When** the relocation question goes unanswered
- **Then** the comment stays, nothing is created, and the report carries an `unresolved (1)` line naming the unanswered question

#### Scenario: Only copy under --all

- **Given** an `--all` run that finds an only copy
- **When** it reports
- **Then** it marks it `held — only copy, relocation not proposed (run scoped to act on it)` and asks nothing

#### Scenario: Only copy under path scope

- **Given** a `PATH …` run that finds an only copy
- **When** it reports
- **Then** it asks the relocation question, exactly as a diff-scoped run would
