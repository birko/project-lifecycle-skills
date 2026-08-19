# The universal layer — the inventory both front doors work from

The single definition of what a lifecycle-ready repo contains. [[new-project]] **creates** this
for a new repo; [[adopt-project]] **reconciles** an existing one against it. One list, two verbs —
a second copy is exactly the drift the layer-parity rule exists to prevent.

**What lives here vs. in SKILL.md.** This file is the *inventory*: which artifacts, who owns each
shape, and what to do when one already exists. `SKILL.md` step 3 carries the *creation detail* —
how to seed the Conventions rulebook, what to put in the architecture overview. Two axes, not two
copies: add an artifact here, describe how to fill it there.

**Changing this file changes both skills.** That is the layer-parity rule, and it is the whole
point of the file existing.

Each row states what the artifact is, which skill owns its shape, and — the part that only matters
for adoption — **what to do when the repo already has one**.

| Artifact | Owner | Already present? |
|---|---|---|
| `README.md` | — | **Leave it.** Offer to append a short "How we work" pointer at the end; never rewrite a human's README. |
| Agent guide (`CLAUDE.md`, or `AGENTS.md` + one-line `@AGENTS.md` bridge) | [[new-project]] seed | **Merge by section.** Add missing `##` sections; never touch an existing one's content. A guide with no `## Conventions` block is the highest-value gap in an adoption — flag it loudly. |
| `docs/BRIEF.md` | [[new-project]] | **Never reconstruct.** See *The adopted-repo brief* below. |
| `docs/architecture.md` | — | Leave it; report if absent. |
| `docs/features/` + `README.md` index | [[feature]] | Create the folder + index if absent. Never regenerate an existing index by hand — that is `/feature status`'s job. |
| `docs/specs/.map.yml` | [[specs]] | Delegate to `/specs init`, which re-discovers and proposes a delta rather than dropping areas. Seed `areas: []` only when the repo has no code yet. |
| `tasks/` (`.config.yml` + `README.md`) | [[tasks]] | Delegate to `/tasks init` — it adopts a pre-skill tree without disturbing it, **and reconciles a config written by an older version**, adding fields it predates and asking for any that are a real choice. Never write these shapes by hand. |
| `CHANGELOG.md` | [[roll-changelog]] | Present → leave. Absent → seed the Keep a Changelog stub, and **offer** a backfill from history; do not backfill unasked, it is a judgement call about what mattered. |
| `.gitignore` | — | Present → check that `.env` / `.env.*` are covered **and** that agent-tool local state is (`.claude/settings.local.json` at minimum); offer the lines if not. Absent → create for the detected stack. |
| `.gitattributes`, `.editorconfig` | — | Create if absent; leave if present. |
| Test harness | [[populate-tests]] | Delegate to `populate-tests` in `adopt` mode. A repo with a working runner is already adopted — say so and move on. |
| CI gate | — | Present → leave. Absent → offer a minimal install→build→test workflow for the detected stack — **but only if the repo can build in isolation**; see *CI a repo cannot pass* below. |

## Delegation follows the row, not the artifact's appearance

**The *already present?* column is the authority; read the whole cell, per row.** Where it names **a
verb to delegate to**, that delegation applies **whether or not the artifact is present**, because
only the owner knows its own current shape — `/tasks init` and `/specs init` are the two rows that
work this way today.

Read the *whole* cell, though, because a cell can name a verb **and** state its own terminating
condition, and then that condition wins. The test-harness row does exactly this: it delegates to
`populate-tests` in `adopt` mode *and* says a repo with a working runner is already adopted. Both
sentences are the row talking — the second tells you what the delegation would have reported, so
honour it and move on rather than running the verb to be told the same thing.

Two kinds of row are **not** delegations at all:

- a row that names a verb only inside a **prohibition** — *"never regenerate an existing index by hand, that is `/feature status`'s job"* forbids hand-editing; it does not ask adoption to run `/feature status` over someone's present index;
- a row that names **no verb** — `docs/BRIEF.md` says *never reconstruct*, the README says *leave it*.

There is no blanket "every owner has an init", and reading one into this rule would send a present
brief to the greenfield scaffolder.

Skipping a delegation because the artifact "looks right" substitutes a shape check for a version
check, and the two differ exactly where it matters: a `tasks/` tree with epics, a README and a
`.config.yml` looks complete from outside while missing a field added since it was written. Presence
is not a version, and the survey cannot see inside someone else's shape.

So **presence decides whether to *create*, never whether to *delegate*** — with one caveat that
bites today: **"nothing to do" is not "up to date."** An init that declines to touch an existing file
has told you it did not act, not that the file matches the current shape. Where that is the whole
answer available, report the row **unknown** and name the init that could not answer; do not upgrade
its silence into a clean bill of health. An init that cannot express a delta is a defect in **that**
skill, and it gets its own task rather than a workaround here.

## The adopted-repo brief

`docs/BRIEF.md` stores the user's requests **verbatim**, and an existing repo usually has no
surviving original ask. **Do not reconstruct one from the README** — a paraphrase presented as
ground truth is precisely what the verbatim rule exists to prevent, and it is worse than an
absent file because it reads as authoritative.

Instead, stamp the adoption:

- An `## Origin` section recording the adoption date, that no original brief exists, and where the project's actual history lives (README, commit log).
- An empty `## Amendments` section. The append-only log starts from the **first request made after adoption**.

## Detect what the repo has — never check for the shape you would have made

The survey's job is to find out what a repo already solved, **not** to check whether it looks like
a repo `new-project` built. Those are different questions, and confusing them produces the one
error adoption must never make: reporting something as missing when it is present in another form.

**A false "missing" is the dangerous direction.** Fill acts on the survey, so "missing" invites
writing — and writing over a working setup is the never-overwrite rule defeated from underneath
rather than broken outright. Observed on real repos: a project with **54 test files** across
sibling `*.Tests` projects reported as having no test harness, because the probe looked only for a
top-level `tests/`; a guide with `## Key Conventions` reported as having no rulebook.

So detect by **evidence**, not by path:

| Row | Evidence, in order |
|---|---|
| Test harness | a test runner in the manifest (xunit, vitest, pytest, `go test`); then `*.Tests`/`*_test.*`/`*.spec.*`/`*Test*.cs` files **anywhere**; then a runner config. Sibling `X.Tests` projects are *the* .NET convention — a missing `tests/` folder means nothing on its own |
| Rulebook | whatever [[verify-conventions]]'s ladder accepts. The two skills must agree on what a rulebook is, rather than each guessing separately |
| Docs | `docs/` is a convention, not a requirement — architecture notes may live in the README, a `wiki/`, or `Documentation/` |
| Changelog | `CHANGELOG.md`, but equally `HISTORY.md`, `NEWS.md`, or a releases section in the README |
| Task tracking | `tasks/`, but a repo may track work in GitHub Issues or Jira alone — that is *tracking*, not an absence |

**Report the state precisely.** The distinctions matter, the number of them does not — this list
grows as real repos turn up conditions it cannot yet express:

- **present** — found where expected, and (in a git work tree) fully tracked.
- **present, uncommitted** — found on disk, but git does not have all of it. **Only meaningful inside a git work tree**: in a directory with no repo yet every path is untracked, which is what the `git init` offer is for, not this state. Probe with `git status --porcelain --untracked-files=all -- <path>`, which answers both halves (the `-all` matters: plain `--porcelain` collapses an untracked directory to `?? docs/specs/` without naming the member, and the member is the thing you have to offer to land): `??` lines are untracked members — the case that matters most for the layer's *directory* artifacts, where a pass may have committed `tasks/README.md` and left `tasks/.config.yml` behind — and ` M` lines are the **tracked-but-uncommitted amendment**, which is the more common one on the upgrade path: an earlier pass that appended `## Conventions` to an already-tracked guide leaves nothing untracked at all, so `git ls-files --others` sees a clean repo and the work is lost just as quietly. (`git ls-files -- <path>` answers "is any of it tracked", a different and useless question here.) (A path that is present but deliberately git-ignored is neither of these — report it `present` and leave it alone.) This state is normally an earlier adoption pass that wrote files and stopped before committing — *the* reason someone re-runs an idempotent adoption, so it belongs on the main path. Reported as plain `present` it hides an artifact the next clone will not have and the next pass will write over, so **offer to land it** instead of counting it done.
- **present, outdated** — there, but in an earlier version of its own shape: a config missing a field the current template has. **Claim it only where something can tell you** — a row whose *already present?* column names a verb, whose delta then *is* the evidence. Where nothing can answer (an agent guide missing a section, whose shape no init owns), the honest label stays `present` with the gap named: reading a schema and judging someone's prose are not the same act. It **composes** with `present, uncommitted` rather than competing — a config that predates a field *and* was never committed is both, and the report says both. Observed in `Presenter`, whose `tasks/.config.yml` predates the `integration:` field: surveyed `present` from the outside, skipped as "already skill-shaped", and the missing field then inferred from `git log` instead — see § *Delegation follows the row, not the artifact's appearance*.
- **present, elsewhere** — found in another location or form. **Say where.** Never silently relocate it, and never offer to create a second one.
- **unknown** — you could not determine it. Honest, and it stops the fill.
- **missing** — you actively looked and it is genuinely absent.
- **missing, not offered** — genuinely absent, and the skill has decided **not** to offer it; the reason travels as part of the state (the CI case below is the standing example). Distinct from plain `missing` because the absence is *adjudicated* rather than merely observed. **The adjudication is re-derived from its evidence on every run, never remembered** — nothing persists it and nothing needs to: the survey and the report are stdout, and the evidence (below) is cheap to re-read. So the moment the evidence changes, the offer comes back on its own, with no bookkeeping. What the state suppresses is the **offer**, not the check and not the status line: re-deriving costs nothing, printing one line of status is not a question, and re-asking *"shall I add this?"* every run is the only thing that was ever the annoyance. A derived state cached as a decision can never expire — which is this rule's own mirror of § *Read the declaration, never infer it* in the consuming project's guide.

*"I could not tell"* is a legitimate answer; *"you don't have it"* when you merely failed to look
properly is a lie that invites a destructive fill. When in doubt, report **unknown** and ask.

**Tracking is orthogonal to the *Already present?* column.** That column decides what to do with an
artifact's **content** — leave it, merge into it, delegate to its owner — and a row reading
*"Present → leave"* still leaves it: landing an untracked file changes nothing inside it. So
`present, uncommitted` adds the offer to commit **on top of** whatever the row says, and never
overrides it. Without this line the two instructions read as a contradiction, and the row wins,
which is how the artifact stays out of history.

**Presence and shape, not content currency.** These states answer *does the artifact exist, and is
it in the shape its owner currently writes* — never *is its prose still true*. A README whose status
section describes the repo three releases ago is `present`: adoption does not fill it, does not
rewrite it, and at most notes the staleness as an aside in the report. The line between the two is
**who can settle it**: a schema delta is read back from the artifact's owner, which is what
`present, outdated` reports, while whether a paragraph still describes reality is a judgement about
content — a content audit, a different job with a different appetite for editing files the repo
owns.

**A count in evidence names where the count came from.** "148 test methods" read off a grep for
`[Fact]`/`[Theory]` is a different claim from 143 tests a runner actually discovered — both were
reported for the same repo, an hour apart. Either name the source ("148 `[Fact]`/`[Theory]`
attributes") or give no number; a bare count reads as verified.

**Never move a repo's files into the canonical layout.** The layer says what a project needs, not
where it must live. A repo that solved it differently has *solved it*.

## CI a repo cannot pass

**Never offer CI to a repo whose build depends on paths outside itself.** Check before offering:
an MSBuild `Import` or `ProjectReference` that escapes the repo root, a `path =` dependency in
`Cargo.toml`, a `file:` dependency in `package.json`, an editable local install in a Python project.

**Resolve the path; do not count the dots.** A reference is only a problem if the resolved target
lands outside the repo root. `..\..\src\Foo\Foo.csproj` from `tests/Foo.Tests/` goes up two
levels and back down *inside* the repo — perfectly normal, and flagging it would skip CI on repos
that could run it fine. Two things do count: a target that resolves outside the root, and a path
rooted at a `$(Variable)` or environment variable, which cannot be resolved at all and therefore
cannot be guaranteed present on a runner. (Written down because counting `..` is the obvious
implementation and it is wrong — it over-reported on the first repo it met.)

When you find one, **skip the offer and say why** — name the dependency and what would have to
exist on a runner for the build to work. A workflow that is red on its first run and stays red is
worse than no workflow: a permanently-failing gate teaches people to ignore CI, and that habit
costs more than the missing gate.

This is the common case, not an edge case, wherever a team shares framework source through an
aggregator rather than a package feed. Observed in `Latent`, a clean .NET solution whose
`Latent.Birko.csproj` imports `$(BirkoSrc)\Birko.Helpers\Birko.Helpers.projitems` — source from a
sibling tree that a runner has no way to obtain.

Making such a repo CI-able is a distribution decision (publish the framework as packages, vendor
it, or check it out in the workflow), not something an adoption pass can settle. Report it as
**missing, not offered** with the offending dependency named, and move on.

**Re-run this check every time; do not remember its verdict.** The three acts come apart:

| Act | Every run? |
|---|---|
| Resolving the dependency paths again | **yes** — it is a manifest read, and it is the only thing that can notice the blocker was fixed |
| Re-opening the offer (*"shall I add a workflow?"*) | **no**, while a path still escapes the root |
| One line of status naming the offending dependency | **yes** — a status line is not a question, and silence would hide a real gap |

So a team that vendors the framework, publishes it, or deletes a dead mapping gets the CI offer back
on the next run without anyone recording anything. **Do not gate the re-offer on a task's state**: a
task can be closed while the dependency is still unresolved, and the manifest cannot be fooled that
way. Where a task does own the blocker, name it in the status line as information — never read it back.

## Ordering

Ground truth and the agent guide first (later steps read them), then `tasks init`, then
`specs init` — the spec map wants the guide's architecture vocabulary, and `/tasks init` may need
the task mode the guide records.

## Rule

**Never overwrite a file the repo already owns.** A conflict is reported for the user to resolve,
never resolved silently. An adoption that quietly rewrites someone's work is worse than one that
does nothing, because it destroys the thing it was meant to preserve.
