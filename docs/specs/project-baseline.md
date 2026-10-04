---
area: project-baseline
generated-at: adc4c27f8733e01ca655b4ec26dfe0a68e190b0f
generated-on: 2026-10-04
sources:
  - skills/adopt-project/INFER.md
  - skills/adopt-project/SKILL.md
  - skills/new-project/LAYER.md
  - skills/new-project/SKILL.md
  - skills/new-project/templates/CLAUDE.seed.md
  - skills/new-project/templates/CONVENTIONS-universal.md
  - skills/new-project/templates/README.seed.md
shaped-by: [FEATURE-001, FEATURE-002, FEATURE-003]
shaped-by-derived: true
shaped-by-unresolved: 7
---

# Giving any repo the same baseline of docs and tracking, new or existing

## Purpose

The project baseline is the "universal layer" every lifecycle-ready repository carries — an agent guide with a living rulebook, a verbatim brief, a README, ignore and editor files, a features home, a spec map, a task tree, a changelog, and a handful of artifacts that only some projects take. Two front doors produce it from one shared inventory: a scaffolder that creates it for a brand-new project by asking the user for facts, and an adopter that surveys an existing repository, reports what it already has in precise states, infers its conventions for confirmation, fills only what is missing by delegating to each artifact's owning skill, and reports what it did. Everything downstream — task tracking, the feature lifecycle, spec harvesting, convention linting — assumes this layer exists and reads what it records, so anyone starting or onboarding a repository onto these skills depends on it.

## Requirements

### Requirement: One inventory drives both front doors

The system SHALL define the layer's artifacts, each artifact's owning skill, and the action to take when the artifact already exists in a single inventory that both the scaffolder and the adopter read, SHALL keep creation detail (how to fill an artifact) in the scaffolder rather than in the inventory, and SHALL have each front door read row properties — owner, `(lazy)`, `(conditional)`, named declarations — off the inventory rather than off a list of its own.

#### Scenario: A row is added to the inventory

- **Given** the inventory gains a new `(lazy)` row tomorrow
- **When** the scaffolder runs and the adopter surveys a repo
- **Then** the scaffolder creates nothing for that row and the adopter reports its absence as `not applicable yet`, without either front door having been edited

#### Scenario: A row names a verb only inside a prohibition

- **Given** the `docs/features/` row says never to regenerate an existing index by hand because that is `/feature status`'s job
- **When** the adopter finds a present features index
- **Then** it does not run `/feature status` over it, because a verb named in a prohibition is not a delegation

### Requirement: The scaffolder hands an existing project to the adopter

The system SHALL, when the scaffolder's target directory is non-empty, confirm before writing and merge per the inventory's "already present?" column, and SHALL stop and redirect to the adopter when the directory already holds a project (source files or git history).

#### Scenario: Target already holds a codebase

- **Given** the user asks to scaffold into `C:\Source\Ledger`, which contains a `.csproj` and a git history
- **When** intake reaches the location question
- **Then** the scaffolder stops and directs the user to `/adopt-project` instead

#### Scenario: Target is non-empty but holds no project

- **Given** the target contains only a stray `notes.txt`
- **When** the scaffolder proceeds
- **Then** it confirms before writing and merges rather than clobbering

### Requirement: Scaffold intake gathers facts and never invents them

The system SHALL gather, in one or two question batches, the project name and absolute location, a one-line purpose, the kind (library / service-or-API / web app / CLI / worker / other), the tech stack, whether to chain a matching installed stack scaffolder, the task tracking mode, the integration model, the task workspace, the license, and — only when the repo is plausibly multi-tool — the agent config file choice; it SHALL never invent a purpose, writing instead that none was stated and pointing at `docs/BRIEF.md`.

#### Scenario: User has no purpose for a scratch repo

- **Given** the user answers the purpose question with "no idea, it's a scratch repo"
- **When** the README and agent guide are written
- **Then** both state that the purpose was not stated and point at `docs/BRIEF.md`, rather than carrying a plausible invented line

#### Scenario: Single-tool repo

- **Given** nothing suggests other agent tools will touch the repo
- **When** intake runs
- **Then** the agent config question is not surfaced and the guide defaults silently to `CLAUDE.md`

### Requirement: The scaffold's integration model and workspace are asked, never defaulted

The system SHALL ask the integration model (`pr-per-task` / `single-branch`) and SHALL NOT let it default; where the user has no opinion it SHALL say the field will be left undeclared and that the documented default applies until set, and SHALL then omit `integration=` from the tasks init; it SHALL put the tasks skill's workspace question verbatim (and its root question only when the answer is its own worktree) and pass the answers as `workspace=` / `worktree-root=`.

#### Scenario: No opinion on integration

- **Given** the user answers the integration question with "don't care"
- **When** `/tasks init` is chained
- **Then** it is invoked without `integration=`, so the config is left without a live `integration:` key and the field is reported unresolved

#### Scenario: Worktree workspace chosen

- **Given** the user answers the workspace question with "its own worktree"
- **When** intake continues
- **Then** the root question is put next, and both answers are passed to the init as `workspace=worktree` and `worktree-root=<path>`

### Requirement: Optional scope grill for substantial projects

The system SHALL offer, never force, a scope grill for non-trivial projects, fold resolved decisions into the README overview and the agent guide's constraints/architecture notes when accepted, and skip the offer silently for a throwaway library or a docs-only repo.

#### Scenario: Service project

- **Given** the kind is service-or-API
- **When** intake finishes
- **Then** the user is offered a scope grill before scaffolding

#### Scenario: Docs-only repo

- **Given** the stack is "none yet / docs-only"
- **When** intake finishes
- **Then** no grill is offered and nothing is said about it

### Requirement: The brief is written first, verbatim, and is append-only

The system SHALL always create `docs/BRIEF.md` before any paraphrase, capturing the user's original request word for word with a capture date and a do-not-rewrite note (the intake answers themselves for a bare scaffold), SHALL keep the opening block immutable, and SHALL append later requirement-changing requests verbatim under an Amendments section with a date and the feature each became.

#### Scenario: Bare throwaway scaffold

- **Given** the user's whole ask is "scaffold me a throwaway library"
- **When** the universal layer is scaffolded
- **Then** `docs/BRIEF.md` is still created, holding that ask verbatim

#### Scenario: Mid-project scope change

- **Given** a scaffolded project later receives "also export to CSV"
- **When** the request is recognised as new scope
- **Then** it is appended verbatim and dated under Amendments, naming the feature it became, and the opening block is untouched

### Requirement: Templates are copied and only their tokens change

The system SHALL create the README and agent guide by copying their templates and changing only lines that carry a `{{…}}` token, SHALL set the README's agent-guide link to whichever file is canonical, and SHALL set the stakeholders token from the brief or intake, defaulting to `project managers, end users`; it SHALL write the assembled guide to `CLAUDE.md` by default, or to `AGENTS.md` with `CLAUDE.md` containing exactly the one-line import `@AGENTS.md` when canonical-AGENTS was chosen, never duplicating the content into both and never using a symlink.

#### Scenario: AGENTS.md canonical

- **Given** intake chose AGENTS.md canonical
- **When** the README and guide are written
- **Then** the README's "full convention" link points at `AGENTS.md`, `AGENTS.md` holds the content, and `CLAUDE.md` holds only `@AGENTS.md`

#### Scenario: No stakeholders named

- **Given** neither the brief nor intake names who the docs serve
- **When** the guide is rendered
- **Then** the stakeholders token is filled with `project managers, end users`

### Requirement: The universal rules are spliced byte for byte, or the guide is reported incomplete

The system SHALL fill the guide's `{{UNIVERSAL_CONVENTIONS}}` token by replacing that one line, at its position, with the entire contents of the universal-conventions template byte for byte (never appended to end-of-file), SHALL verify before finishing that the block is identical and sits inside `## Conventions`, and SHALL stop and report the guide incomplete — never composing a substitute — when that template cannot be read.

#### Scenario: Splice lands at the token

- **Given** the seed guide has been copied to `CLAUDE.md`
- **When** the universal block is inserted
- **Then** it appears between `### Testing` and `## Commands`, identical to the template, not after `## Commands`

#### Scenario: Universal template unreadable

- **Given** the runner cannot read the skill's `templates/` directory
- **When** it reaches the splice
- **Then** it stops and reports the guide incomplete instead of writing the rules from memory

### Requirement: A seeded guide carries the lifecycle, the altitude table and the universal rulebook

The system SHALL seed the agent guide with a header naming stack, kind, task tracking, features, specs and changelog; a ten-step feature lifecycle from idea to production feedback; a ground-truth-and-altitude table routing requirement changes to the brief, behaviour changes to a feature's decisions, implementation detail to commits or architecture, word meanings to `docs/glossary.md` and hard-to-undo choices to `docs/adr/` (noting the last two are written on first use, not scaffolded); `## Architecture`; a `## Conventions` rulebook with per-project subsections and the universal comment rule, register-on-introduce rule and working rules (task-first gate, plan before implementing, spawn discovered scope, the close-step review passes as merge gate, generated files and status changes owned by their verbs, no `Co-Authored-By:` trailers); and `## Commands`.

#### Scenario: Freshly scaffolded guide

- **Given** a scaffold has completed
- **When** a reader opens `CLAUDE.md`
- **Then** it finds the task-first gate, the comment rule's delete-then-search table and the five-row altitude table, and the comment rule sits between `<!-- comment-rule:start -->` and `<!-- comment-rule:end -->` markers

#### Scenario: Merge deferred in the seeded working rules

- **Given** a task's merge is deferred to an external reviewer
- **When** the seeded close rule is followed
- **Then** the task stays `in-progress` with a `blocked:` field, not `done`

### Requirement: Rulebook subsections are filled only where a token marks them

The system SHALL fill only the `## Conventions` subsections that carry a token — framework/stack from the chosen stack, code structure and naming with the stack's idiomatic defaults, testing from the stack — and leave every untokened subsection exactly as written; it SHALL ask one targeted question for a UI kind's UI/UX subsection, delete that subsection only for kinds with no human-facing surface, and keep it retitled **Output / UX rules** for a CLI/TUI whose output humans read; no subsection SHALL ship a dangling token.

#### Scenario: Python library

- **Given** a Python library with no human-facing surface
- **When** the rulebook is filled
- **Then** Naming carries `snake_case`/src-layout defaults, the UI/UX subsection is deleted, and no `{{…}}` remains

#### Scenario: CLI with a readability requirement

- **Given** a CLI whose brief asks for readable reports
- **When** the rulebook is filled
- **Then** the UI/UX subsection is kept and retitled Output / UX rules

### Requirement: The remaining always-created scaffold artifacts

The system SHALL scaffold a stack-appropriate `.gitignore` that always includes `.env` and `.env.*` followed by `!.env.example`; a `.gitattributes` with `* text=auto eol=lf`; an `.editorconfig`; a Keep a Changelog `CHANGELOG.md` stub with `## [Unreleased]`; `docs/features/` with a README index rendered from the feature skill's template (one `idea` row per seeded stub, otherwise empty); `docs/specs/.map.yml` from the specs template with `ignore:` globs written for the chosen stack; a short but real `docs/architecture.md` marked living; and, when MIT or Apache-2.0 was chosen, a full `LICENSE` text with the current year and a holder derived from `git config user.name`, asking only if that is empty.

#### Scenario: Node project

- **Given** the stack is TypeScript/Node
- **When** `.gitignore` is written
- **Then** it contains `node_modules/`, `dist/`, `.env`, `.env.*` and, after them, `!.env.example`

#### Scenario: Proprietary license

- **Given** intake chose proprietary
- **When** the layer is scaffolded
- **Then** no `LICENSE` file is written and the README's license line notes the posture

### Requirement: A multi-feature brief is persisted as a traceable roadmap

The system SHALL, when the brief lists several capabilities, write a requirement → feature matrix in the seed EPIC with no hand-typed status column, give every stated requirement a tracked home (an unmapped one being a planning bug), seed every planned requirement as a `status: idea` feature folder with planned STORY stubs, and give soft/qualitative requirements their own tracked feature.

#### Scenario: Brief with a soft requirement

- **Given** a brief asking for import, export, reporting and "make it feel fast"
- **When** the layer is scaffolded
- **Then** four `idea` feature folders exist, including one for performance, and the features index lists all four

### Requirement: Task tracking is initialised through its owner

The system SHALL create `tasks/` by chaining `/tasks init` with the resolved mode and, where declared, integration, workspace and worktree root, and SHALL never hand-write those shapes; for hybrid-GitHub it SHALL resolve the `owner/name` slug before writing the config (doing the remote step early), and SHALL fall back to `local` mode with a pointer to `/tasks migrate` when the user defers the remote.

#### Scenario: Hybrid-GitHub with remote deferred

- **Given** the user chose hybrid-GitHub but declines to create or name a remote
- **When** task tracking is initialised
- **Then** `/tasks init` runs with `mode=local` and the user is told they can switch with `/tasks migrate`

### Requirement: Stack wiring, source root, test harness and CI stub

The system SHALL invoke a confirmed stack scaffolder and let its layout win (no generic `src/`), otherwise create a minimal stack-idiomatic skeleton with source and test roots (none for docs-only, none for .NET); SHALL chain `/populate-tests adopt` for any stack with a source root; and SHALL decide whether to offer a CI stub by the inventory's CI row and its isolation check, run after the stack scaffolder as a manifest read, writing a one-job install → build → test workflow only when the check allows it.

#### Scenario: Scaffolder imports a sibling tree

- **Given** the chained stack scaffolder writes a project importing `$(BirkoSrc)\Birko.Helpers\Birko.Helpers.projitems`
- **When** the CI bullet is reached
- **Then** no workflow is written, and the closing checklist says once that CI was skipped because the build imports `$(BirkoSrc)`

#### Scenario: Go project

- **Given** the stack is Go with no stack scaffolder
- **When** the skeleton is created
- **Then** it uses a flat or `cmd/<app>/main.go` + `internal/` layout with `*_test.go` beside source, and `go.mod`

### Requirement: Greenfield conditional rows are settled after the scaffolder, and asked when unsettled

The system SHALL settle the `.env.example` and `Dockerfile` rows after the stack scaffolder has run, using the inventory row's question about the repo (not a kind list) with the declared kind as evidence only; where evidence does not settle it, SHALL ask the row's verbatim question with Yes / No / Not sure yet; SHALL record whether the answer was `declared` or `derived`; and on no answer or "Not sure yet" SHALL write nothing, never an empty `.env.example`, and report the row `unknown` in the closing checklist naming the missing evidence.

#### Scenario: User not sure about env vars

- **Given** a worker project whose scaffolded code does not settle whether it needs a runtime variable
- **When** the user answers "Not sure yet"
- **Then** no `.env.example` is written and the checklist says once that nobody could confirm whether the project needs an env var to start

#### Scenario: Service declared by the user

- **Given** the user answers Yes to the Dockerfile question
- **When** step 5 completes
- **Then** a minimal multi-stage `Dockerfile` and `.dockerignore` are offered, and the answer is recorded as `declared`

### Requirement: Git root confirmed, initial commit offered, remote offered

The system SHALL never silently `git init`: it SHALL resolve `git rev-parse --show-toplevel` and report an existing own repo, ask whether to track an untracked directory (default Yes), and, when an ancestor repo captures the directory, surface the ancestor and offer a nested repo, removal of a verified-empty accidental ancestor `.git`, or leaving it; it SHALL offer one `chore: initial scaffold` commit when the repo has no commits (warning on decline that the first `/tasks pick` will need one), commit nothing else unasked, and offer — never auto-run — remote creation for hybrid-GitHub.

#### Scenario: Ancestor repo captures the project

- **Given** `rev-parse` in `C:\Source\MyApp` returns `C:\Source`
- **When** the git step runs
- **Then** the user is asked whether `C:\Source` is the intended root, with the three options, and nothing is assumed

#### Scenario: User declines the initial commit

- **Given** a freshly initialised repo
- **When** the user declines `chore: initial scaffold`
- **Then** the run warns that the first `/tasks pick` must make that commit before it can cut a branch

### Requirement: The scaffold's closing checklist reports unknowns, derived Nos and skipped CI

The system SHALL print a next-step checklist naming `/feature new`, `/tasks new` and `/domain`, a stack build/run hint and CI/Docker reminders when generated; SHALL state once each conditional row that ended `unknown`; SHALL print one line for a conditional row that settled No by derivation — naming what each component does against the row's own condition, never kind labels — and stay silent for a declared No; and SHALL state once a CI stub skipped under the isolation rule, naming the dependency.

#### Scenario: Derived No for Dockerfile

- **Given** the Dockerfile row was settled No by classifying a UI app, an importer and a library
- **When** the checklist prints
- **Then** it carries a line such as "no Dockerfile: none of the three components is deployed as a running service — the UI app and the importer both run on a machine and exit, the library has no entry point"

#### Scenario: Declared No

- **Given** the user said the project is not deployed as a service
- **When** the checklist prints
- **Then** no Dockerfile line appears

### Requirement: Adoption is idempotent and writes nothing when nothing is owed

The system SHALL let adoption be re-run at any time, never overwriting and never writing unasked; a re-run that finds nothing missing, nothing `present, uncommitted` and no owner reconciliation SHALL write nothing at all, while a repo with nothing missing MAY still have an artifact landed or reconciled.

#### Scenario: Fully current repo

- **Given** every row is present, committed and every delegated owner reports already current
- **When** adoption is re-run
- **Then** no file changes and no commit is offered

#### Scenario: Earlier pass left a file uncommitted

- **Given** nothing is missing but `tasks/.config.yml` is on disk and untracked
- **When** adoption is re-run
- **Then** it offers to land that file, even though no artifact is missing

### Requirement: The survey classifies every row by evidence into a precise state

The system SHALL survey every inventory row before writing anything, classify each into exactly one of `present`, `present, uncommitted`, `present, outdated`, `present, elsewhere`, `unknown`, `missing`, `missing, not offered`, `not applicable`, or `not applicable yet` (with `present, outdated` and `present, uncommitted` composable), detect by evidence rather than by path, report `unknown` rather than `missing` when in doubt, and report present-but-thin artifacts as `present` with the gap named; it SHALL claim `present, outdated` only for a row whose "already present?" cell names a verb to delegate to, using that verb's reported delta as the evidence, keeping a shape no verb owns at `present` with the gap named.

#### Scenario: Tests in sibling projects

- **Given** a .NET repo with no `tests/` folder but 54 test files across sibling `*.Tests` projects that the CI workflow invokes
- **When** the test-harness row is surveyed
- **Then** it is reported present, not missing, because the gate's observed execution is checked first

#### Scenario: Shell test suite

- **Given** CI runs `.github/workflows/skills-lint-test.sh`, which matches no test-file glob
- **When** the test-harness row is surveyed
- **Then** it is present, because what the gate invokes is the suite whatever it is called

#### Scenario: Task tracking in Jira only

- **Given** no `tasks/` folder but the team tracks work in Jira
- **When** the task-tracking row is surveyed
- **Then** the repo is not reported as having no tracking

#### Scenario: Guide missing a section

- **Given** an agent guide with no counterpart to the seed's `## Commands`
- **When** it is surveyed
- **Then** it is `present` with the missing section named, not `present, outdated`

### Requirement: Uncommitted layer artifacts are detected by the porcelain rule

The system SHALL report `present, uncommitted` when the artifact is on disk and `git status --porcelain --untracked-files=all -- <path>` prints anything, staged or unstaged, except deletions (`D ` / ` D`) and unmerged paths (any `U`, or `AA`); SHALL treat git-ignored paths as plain `present`; and SHALL not claim the state when `git rev-parse --show-toplevel` resolves to an ancestor rather than the adopted directory.

#### Scenario: Staged but never committed

- **Given** an earlier pass wrote and staged the layer, so the probe prints `A  tasks/.config.yml`
- **When** the row is surveyed
- **Then** it is `present, uncommitted`

#### Scenario: Staged member deletion

- **Given** `tasks/` is on disk and the probe prints `D  tasks/.config.yml`
- **When** the row is surveyed
- **Then** it is not `present, uncommitted`, so no offer is made that would commit the removal

#### Scenario: Directory captured by an ancestor

- **Given** the adopted directory is untracked inside an ancestor repo, so the probe prints `?? subproject/CLAUDE.md`
- **When** the survey compares the toplevel with the adopted directory
- **Then** the state is not claimed and the resolved ancestor is surfaced to the user instead

### Requirement: Location deviations compose with every row

The system SHALL report an artifact found at another path, under another name, or with its purpose served inside another file as `present, elsewhere`, saying where, never relocating it and never offering a second; prose that merely mentions what an artifact would contain SHALL leave the row `missing` with the documenting location named; files the agent guide links are part of the one guide artifact, and a same-prefix file nothing links is not.

#### Scenario: Licence under another name

- **Given** an open-source repo with `License.md` and no `LICENSE`
- **When** the LICENSE row is surveyed
- **Then** it is `present, elsewhere` naming `License.md`, and no `LICENSE` is offered

#### Scenario: Deployment guide names an env var

- **Given** a deployment guide documents a required API key and a recipe for it, but no `.env.example` exists
- **When** the `.env.example` row is surveyed
- **Then** it is `missing`, and the report names the deployment guide as where the fact is already documented

#### Scenario: Unlinked CLAUDE-prefixed file

- **Given** `CLAUDE-prompt.md` sits beside the guide and nothing links it
- **When** the guide row is surveyed
- **Then** that file is neither folded into the guide nor reported as a gap

### Requirement: Lazy rows are never created and report `not applicable yet`

The system SHALL create nothing the inventory marks `(lazy)` — today `docs/glossary.md` and `docs/adr/`, owned by `/domain` — at scaffold or adoption, naming `/domain` in the scaffolder's next-step checklist; the adopter SHALL report an absent lazy artifact as `not applicable yet`, never count it as missing, never fill it and never offer to; a present glossary SHALL be left and treated as current, and a present `docs/adr/` SHALL be left with no shape sweep.

#### Scenario: New project finishes

- **Given** a scaffold completes
- **When** the tree is inspected
- **Then** neither `docs/glossary.md` nor `docs/adr/` exists, and the checklist includes "Vocabulary & decisions: `/domain`"

#### Scenario: No glossary but candidates found

- **Given** no `docs/glossary.md` and the inference pass found `Tenant`/`Organization` as suspected synonyms
- **When** the report is written
- **Then** the glossary row reads `not applicable yet`, not under a gap heading, and the candidates are handed to `/domain` as a finding

### Requirement: Conditional rows turn on each row's own question, classified per component

The system SHALL settle each `(conditional)` row by the condition the row names — `.env.example` on whether anything here requires an environment variable to run, `Dockerfile` on whether anything here is deployed as a running service, `LICENSE` on licensing posture — with kind used only as evidence and a declared kind outranking signals; one component answering yes SHALL settle Yes, No SHALL require every component to be classified as no, any unclassifiable component with no yes SHALL yield `unknown`, and a repo with no components of its own SHALL settle No; "here" SHALL be the surveyed work tree only, "requires" SHALL exclude optional overrides with committed defaults and build-time variables.

#### Scenario: Entry point delegates to an absent library

- **Given** a package whose `main` calls `dispatch(channel, plan.steps)` from an uninstalled library, and no other component answers yes
- **When** the Dockerfile and `.env.example` rows are surveyed
- **Then** both are `unknown`, naming that component, and are asked in step 2's round — not `not applicable`

#### Scenario: Build-time variable only

- **Given** a desktop app whose only environment read is the MSBuild property `BIRKO_SRC`
- **When** the `.env.example` row is surveyed
- **Then** it is `not applicable`

#### Scenario: Aggregator with no components

- **Given** a repo root holding only `docs/` and `tasks/`, whose solution registers projects in sibling repos
- **When** the conditional rows are surveyed
- **Then** both component-based rows settle `not applicable`, and the sibling projects are not evidence

#### Scenario: Bare copyright notice

- **Given** a repo whose only licence-related text is a `<Copyright>` element in a project file
- **When** the LICENSE row is surveyed
- **Then** it is `unknown` and asked in the round, because a bare copyright notice settles neither posture

### Requirement: Named declarations are probed by the survey and asked only when absent

The system SHALL, for every present artifact whose row names a declaration (today `integration:` and `workspace:` in `tasks/.config.yml`), grep for a live, anchored, uncommented key (`^integration:`, `^workspace:`), treat a commented line as absent, report an outstanding declaration on the row as `present` with the gap named, carry it into the one round, and never re-ask one the file carries. For `worktree-root:` the two files disagree: the layer inventory lists it as a declaration to probe once `workspace: worktree` is answered, while the adopter treats a worktree with no root as settled and never asks the root question during adoption. The adopter's reading is the one specced in the scenario below.

#### Scenario: Commented example only

- **Given** `tasks/.config.yml` contains `# integration: <pr-per-task|single-branch>` and no live key
- **When** the survey probes the declaration
- **Then** `integration:` is outstanding and is asked in step 2's round

#### Scenario: Declaration already carried

- **Given** `tasks/.config.yml` has `integration: single-branch` on its own line
- **When** adoption is re-run
- **Then** integration is not asked

#### Scenario: Worktree with no root

- **Given** the config carries `workspace: worktree` and no `worktree-root:`
- **When** the survey runs
- **Then** this is reported as settled and no root question is asked

### Requirement: Agent-guide sections are matched by meaning; the guide's rules are not surveyed

The system SHALL read the seed guide's `##` headings and bodies as the section inventory on every run, judge whether a guide answers each by meaning rather than heading text, decide `## Conventions` by the verify-conventions rulebook ladder with rules reachable through a linked companion counting and rules woven through the guide counting, report a section whose content lives in another file as `present` saying where, name genuinely ambiguous matches as undetermined for the round, flag loudly a guide with no reachable conventions, and SHALL NOT diff the rules inside a present guide against the seed.

#### Scenario: Slovak guide

- **Given** a guide with 19 Slovak `##` sections, none matching a seed heading by text
- **When** sections are matched
- **Then** sections answering architecture, conventions and commands resolve as present by meaning, and a section whose match is debatable is reported undetermined with the reason

#### Scenario: Older-vintage guide

- **Given** a guide answering every seed section but lacking the task-first gate wording
- **When** the guide row is surveyed
- **Then** it is `present` and no rule-level gap is reported

#### Scenario: Commands only in the README

- **Given** a guide with no commands section while `README.md` §§ Build / Run carry that content
- **When** sections are matched
- **Then** the section is `present`, naming the README, and no second copy is offered

### Requirement: Ignore coverage counts only the repo's own ignore file

The system SHALL check that a present `.gitignore` covers `.env`, `.env.*` and agent-tool local state (at least `.claude/settings.local.json`) — and, where the `.env.example` row applies, carries a following `!.env.example` — using `git check-ignore -v` and counting only a source in the repo's own ignore file; a global-ignore hit SHALL be reported as a gap with the line offered and a note that nothing is currently at risk, and an uncommitted but correct ignore file SHALL be reported both covered and `present, uncommitted`.

#### Scenario: Ignored only by the global excludes file

- **Given** `git check-ignore -v .claude/settings.local.json` names `~/.config/git/ignore` as the source
- **When** the `.gitignore` row is surveyed
- **Then** it reports a gap, offers the line, and says nothing is currently at risk on this machine

### Requirement: The survey table prints before any write, and completeness waits for the owners

The system SHALL resolve stack, component behaviour, declared kind, licensing posture, test runner, git remote, ancestor capture, uncommitted layer files and declaration probes before printing, SHALL print the survey as a table before anything is written, list defects beneath it rather than as rows, and treat the table as a barrier on writes rather than the end of the run; a "complete" table SHALL end the run only when no row names a verb to delegate to or every such verb has answered, and no defect is outstanding.

#### Scenario: All rows present on an adopted repo

- **Given** every row surveys `present` and the `tasks/` row names `/tasks init`
- **When** the table prints
- **Then** the run continues to the delegation rather than ending, because the owner has not yet spoken

#### Scenario: Complete table with a defect

- **Given** every row is current but the survey found a script pointing at a moved directory
- **When** the table prints
- **Then** the defect is listed beneath it and the run continues to file it

### Requirement: Conventions are inferred from the code, proposed with evidence, and only where uncovered

The system SHALL infer conventions per rulebook subsection (framework/stack, code structure, naming, testing, UI/UX only where a human surface exists) from the repo's own source, showing each proposal with a count and two or three representative paths; SHALL propose at roughly 80%+ of applicable files and at least 5 files, ask at roughly 20–80%, and stay silent under 20% or under 3 files unless structural or security-relevant; SHALL drop any unconfirmed inference; and SHALL judge coverage per subsection, skipping proposals for covered ones, offering (not running) a round for a thinly answered one, never proposing beside an existing rule, and saying what it skipped and what covered it in this step and in the final report.

#### Scenario: Prevalent pattern

- **Given** 24 of 26 handlers return a Result type
- **When** proposals are built
- **Then** "Handlers return a Result type rather than throwing [24/26 files]" is proposed with two example paths, asking whether to record it as a Code structure rule

#### Scenario: Rulebook already covers everything

- **Given** a guide whose flat rule list answers all five subsections
- **When** step 2 runs
- **Then** no proposals are made, the skip and its covering evidence are announced, and nothing is written for proposals

#### Scenario: Too little code to infer

- **Given** a repo too small to read rules from
- **When** inference runs
- **Then** the subsections are left empty and recorded as pending a real decision

### Requirement: Glossary candidates and split findings survive a skipped round

The system SHALL collect recurring domain nouns and suspected synonyms as glossary candidates and hand them to `/domain`, appending confirmed terms through `/domain` when `docs/glossary.md` exists; it SHALL report glossary candidates and 20–80% split findings even when every subsection is covered — stated as findings, not asked — and SHALL, meanwhile, record candidates in the guide's § Conventions › Naming marked unresolved, retiring that copy once the glossary exists.

#### Scenario: Migration in flight on a covered repo

- **Given** a fully covered rulebook and two error-handling shapes in a 50/50 split
- **When** step 2 skips the proposal round
- **Then** the split is reported as a finding and no question is asked about it

### Requirement: Inferences and declarations go to the user in one frontier round

The system SHALL put proposals, outstanding declarations (task-tracking mode, integration model, task workspace via the tasks init's verbatim question, canonical guide file, licence posture — each only when the survey found its artifact missing or its declaration outstanding), unresolved `unknown` conditions, undetermined guide sections and the empty `## Amendments` offer into one numbered round with recommended answers, never asking what reading the code would answer, and SHALL pass the answers to the owning verb (`/tasks init mode= integration= workspace= worktree-root=`) so nothing is asked twice; a skipped proposal round with one outstanding declaration SHALL still produce a one-question round.

#### Scenario: Dense rulebook, missing integration

- **Given** a rulebook covering every subsection and a `tasks/.config.yml` with no live `integration:` key
- **When** step 2 runs
- **Then** proposals are skipped and announced, and a round carrying exactly the integration question is opened

#### Scenario: Repo already has a guide

- **Given** a repo with a `CLAUDE.md`
- **When** the round is built
- **Then** the user is not asked whether the canonical guide should be `CLAUDE.md` or `AGENTS.md`

### Requirement: Gaps are filled in dependency order by delegation, never overwriting

The system SHALL fill in the inventory's order — brief and agent guide, then `docs/features/`, then `/tasks init`, then `/specs init`; SHALL never overwrite a file the repo owns, reporting the conflict instead; SHALL not fill an `unknown` row; SHALL always delegate where a row names a verb regardless of presence, unless the row's own cell states a terminating condition (a working test runner is already adopted); SHALL suppress a prescribed action when the repo already carries what it would produce, reporting the suppression, while firing it when unsure; and SHALL map the owner's answer to the report — already current → `present`, brought up to date → `amended`, created → created, declined or impossible → stays `present, outdated`, unable to tell → `unknown` naming the verb.

#### Scenario: README already has the pointer

- **Given** a README that already ends with a "How we work" pointer
- **When** the README row's append offer would fire
- **Then** it is suppressed and the report says so

#### Scenario: Working test runner

- **Given** a repo whose CI runs `dotnet test` successfully
- **When** the test-harness row is filled
- **Then** `/populate-tests adopt` is not run and the row reports the repo already adopted

#### Scenario: Owner cannot tell

- **Given** an init that declines to touch an existing file without reporting a delta
- **When** the row is reported
- **Then** it reads `unknown`, naming that init, and the user is not asked whether to create the present file

### Requirement: Uncommitted artifacts are landed by an itemised offer, before any rewrite

The system SHALL land a `present, uncommitted` artifact rather than rewrite it, through one itemised offer listing each path (directory rows listing their members) that accepts a subset, stating that adoption cannot tell whose work it is and reporting any self-attribution beside the path without treating it as licence; the landing SHALL be ordered before any re-run that would rewrite the same file, including step 3c's regeneration.

#### Scenario: Leftover plus user work in one directory

- **Given** `tasks/.config.yml` is an earlier pass's leftover and `tasks/README.md` is modified by the user
- **When** the landing offer is made
- **Then** both paths are listed separately and the user can accept only `tasks/.config.yml`

#### Scenario: Self-attributed file

- **Given** a `.gitignore` block reading "added by adopt-project 2026-08-18" that is untracked
- **When** the offer is made
- **Then** the attribution is shown beside the path, and the file is still not committed without the user's yes

### Requirement: An adopted repo's brief is stamped, never reconstructed

The system SHALL never reconstruct `docs/BRIEF.md` from a README; for a repo with no surviving ask it SHALL write an `## Origin` section (adoption date, that no original brief exists, where history lives) and an empty `## Amendments`; where a dated verbatim ask survives it SHALL leave the text alone, report the row `present`, suppress the Origin stamp, and offer the empty `## Amendments` heading as an item in the one round.

#### Scenario: Surviving original ask

- **Given** `docs/BRIEF.md` carries a dated verbatim request and no Amendments heading
- **When** adoption runs
- **Then** no `## Origin` is written, and the round includes a yes/no on appending an empty `## Amendments`

### Requirement: CI is never offered to a repo that cannot build in isolation, and the verdict is re-derived

The system SHALL offer a minimal install → build → test workflow to a repo with no CI gate only when no build input escapes the repo root unobtainably — resolving paths rather than counting `..`, treating restore-provided and SDK-defined variables as obtainable and sibling-tree variables or out-of-root relative paths as blockers, and never scanning `obj/` or `bin/`; otherwise it SHALL report `missing, not offered` naming the dependency, re-resolving every run, suppressing only the offer and printing the status line each time without reading any task's state.

#### Scenario: NuGet package import in obj

- **Given** a console app whose `obj/*.nuget.g.props` imports `$(NuGetPackageRoot)…`
- **When** the CI row is surveyed
- **Then** CI is offered, because `obj/` is not scanned and the variable is obtainable

#### Scenario: Blocker later fixed

- **Given** a previous run reported `missing, not offered` for `$(BirkoSrc)` and the team has since vendored the framework
- **When** adoption is re-run
- **Then** the paths resolve inside the root and the CI offer returns without anything having been recorded

### Requirement: Defects found during adoption are always filed, in the right tracker

The system SHALL file every defect the adoption turns up as a task through `/tasks new` in the adopted repo's tracker whether or not the user chooses to fix it; SHALL finish the layer fill before fixing unless the defect blocks a delegation, in which case it is handled there with the reason reported; SHALL file only after `/tasks init` has run, reporting at step 1 and filing later when no `tasks/` exists yet; SHALL require a regression check on a fix or a recorded reason none is possible; SHALL need the user's go-ahead to repair a repo file; and SHALL NOT file into the adopted repo a `unknown` caused by the rule running out, reporting it instead as a finding against these instructions.

#### Scenario: User declines the fix

- **Given** adoption finds a build script that references a deleted path
- **When** the user says "not now"
- **Then** a task describing the defect is created in the adopted repo's `tasks/`, and the report lists its id

#### Scenario: Broken build blocks the harness

- **Given** the repo's build is broken by an undeclared reference
- **When** the test-harness delegation is reached
- **Then** the defect is handled at that delegation and the report says why it jumped the queue

#### Scenario: Row cannot decide

- **Given** a runner enumerated every config source and environment read and the `.env.example` row still cannot classify the evidence
- **When** the report is written
- **Then** the finding appears under Defects found against these instructions, naming the row and the evidence, and no task is filed in the adopted repo

### Requirement: Generated files invalidated by the adoption are regenerated by their owners

The system SHALL derive, from what this run created and the inventory's Owner column, which generated files now have a new input, and re-run their owning verbs (today `/tasks triage` after creating `docs/features/`; spec bodies stay an offer); it SHALL render first and compare, writing and reporting nothing for a no-op, regenerating for derivable additions, and stopping to report when non-derivable content would be removed; it SHALL never hand-shape a generated file, and the regenerated files SHALL ride in the adoption commit.

#### Scenario: Features folder created on an adopted repo

- **Given** adoption created `docs/features/` in a repo whose `tasks/README.md` already existed
- **When** step 3c runs
- **Then** `/tasks triage` is re-run and `tasks/README.md` is reported under `regenerated`, naming the verb

#### Scenario: Dashboard carries imported provenance

- **Given** `tasks/README.md` carries a hand-written note about where the tree was imported from
- **When** the regeneration would remove it
- **Then** the run stops, reports what would be lost and where it belongs, and writes nothing

### Requirement: The adoption report states outcomes, per-state reasons and defects separately

The system SHALL report outcomes under created, amended (with what changed inside), left alone (with why) and regenerated (naming file and verb, including declined or blocked ones); SHALL give each surveyed state not absorbed by those buckets its own bucket, owing today: where for `present, elsewhere`, the owner's delta and whether it was reconciled for `present, outdated`, each path and whether its offer was taken for `present, uncommitted`, which of `unknown`/`missing` and why (and which kind of unknown), the re-derived reason for `missing, not offered`, and that absence is correct for `not applicable yet`; SHALL list defects in their own section with task ids; SHALL treat content staleness as an aside; and SHALL end with `/feature new` and `/tasks new` as next steps.

#### Scenario: Upgrade run

- **Given** an adoption appended `## Conventions` to an existing guide
- **When** the report is written
- **Then** the guide appears under amended with "section appended", never under created

#### Scenario: Stale README prose

- **Given** a README whose status section describes the repo three releases ago
- **When** the report is written
- **Then** the staleness is noted as an aside, not as a bucket, and the README is left alone

### Requirement: Adoption's git policy is read, never inferred

The system SHALL read branch and merge policy from `tasks/.config.yml`'s `integration:` field, asking and backfilling it when absent and never inferring it from `git log`; SHALL never delete a branch on inference; SHALL ask before `git init` and surface an ancestor repo's root; SHALL offer the adoption commit and never commit unasked; and SHALL add no `Co-Authored-By:` trailers to any commit either front door creates.

#### Scenario: Squash-merge-looking history

- **Given** a repo whose `git log` looks like squash merges and whose config has no `integration:`
- **When** adoption decides git policy
- **Then** it asks for the integration model and backfills it, rather than concluding `pr-per-task` from the log
