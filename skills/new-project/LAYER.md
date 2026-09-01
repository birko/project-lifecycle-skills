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
| Agent guide (`CLAUDE.md`, or `AGENTS.md` + one-line `@AGENTS.md` bridge) | [[new-project]] seed | **Merge by section.** Add missing `##` sections; never touch an existing one's content. **The section inventory is [templates/CLAUDE.seed.md](templates/CLAUDE.seed.md)'s own `##` headings — read them off it, and match by meaning per § *Matching a guide's sections*.** **A companion the guide links (`CLAUDE-*.md` and the like) is part of this one artifact** — not a separate row, not `present, elsewhere` — and is classified by **existence and role only** — its prose is content, not shape. See § *Location is orthogonal too*. A guide with no `## Conventions` block is the highest-value gap in an adoption — flag it loudly. **The rules *inside* a present section are content, and this row does not survey them** — see § *A guide's vintage is not surveyable*. |
| `docs/BRIEF.md` | [[new-project]] | **Never reconstruct.** See *The adopted-repo brief* below. |
| `docs/architecture.md` | — | Leave it; report if absent. |
| `docs/glossary.md` **(lazy)** | [[domain]] | **Never create.** The layer includes a glossary; the file appears on the first term worth recording — see § *Lazily-created rows*. Absent → **not applicable yet**. Present → **leave it, and it is current**: the shape is free prose, so there is nothing an owner could find out of date. Whether its *content* still matches the code is `/domain`'s cross-reference pass — a content audit, offered, never run by a fill. |
| `docs/adr/` **(lazy)** | [[domain]] | **Never create the directory.** It appears with its first record, and only [[domain]]'s three-part bar can justify one. Absent → **not applicable yet**: nothing observable at scaffold or adoption time can decide that a past decision *owed* a record — that is a judgement, not a probe. Present → **leave it.** Each record's four parts are checked when that record is written, so adoption has no shape to reconcile and runs no sweep. **That is a narrower claim than "current"**: a record can carry all four parts and still cite a rule that has since changed, or state a decision the code no longer matches — drift a parts-check cannot see, because nothing is missing. Adoption does not audit that (it is content, not shape — see § *Presence and shape, not content currency*); `/domain`'s cross-reference pass is where it belongs. Measured 2026-08-22: a cold read of seven records found three such drifts, none of them a missing part. |
| `docs/features/` + `README.md` index | [[feature]] | Create the folder + index if absent. Never regenerate an existing index by hand — that is `/feature status`'s job. |
| `docs/specs/.map.yml` | [[specs]] | Delegate to `/specs init`, which re-discovers and proposes a delta rather than dropping areas. Seed `areas: []` only when the repo has no code yet. |
| `tasks/` (`.config.yml` + `README.md`) | [[tasks]] | Delegate to `/tasks init` — it adopts a pre-skill tree without disturbing it, **and reconciles a config written by an older version**, adding fields it predates and asking for any that are a real choice. Never write these shapes by hand. **Declaration this owner needs: `integration:` in `.config.yml`** — probe for it in the survey per § *A named declaration is not a version*, since the owner cannot be handed an answer nobody was asked for. |
| `CHANGELOG.md` | [[roll-changelog]] | Present → leave. Absent → seed the Keep a Changelog stub, and **offer** a backfill from history; do not backfill unasked, it is a judgement call about what mattered. |
| `.gitignore` | — | Present → check that `.env` / `.env.*` are covered **and** that agent-tool local state is (`.claude/settings.local.json` at minimum); offer the lines if not. **Covered means covered by the repo's own ignore file, not the machine's** — see § *Covered means covered in the repo*, which also settles how this composes with `present, uncommitted`. Absent → create for the detected stack. The `.env` check pairs with the `.env.example` row below: `.env.*` **matches `.env.example` too**, so a `!.env.example` negation must follow it or the committed template is ignored and every later survey reports it `present` without it ever reaching history. Check for the negation wherever that row applies. |
| `LICENSE` **(conditional — on licensing posture, not kind)** | [[new-project]] seed | **The condition is not the project kind**, so the kind detection cannot answer it. Evidence for the posture: a licence line in the README, a `license:` field in a package manifest, an SPDX header in sources. Open posture and no `LICENSE` file → **missing** — *report it; filling is out of scope here*. Proprietary or explicitly unlicensed → **not applicable**. **No evidence either way → `unknown`, and ask in step 2's question round** — never `not applicable`, which is how the one gap this row exists for disappears. Present → **leave it**: a licence is a legal choice, not a shape an owner verb reconciles. |
| `.env.example` **(conditional — does anything here *require* an environment variable to run?)** | [[new-project]] seed | Yes → absent is **missing**; it is the documented, valueless template of required env vars, and the real `.env` stays ignored *except for this file* (see the `.gitignore` row). No — a library, a CLI, a desktop app — → **not applicable**. Cannot tell → **unknown**, resolved in step 2's round. **A build-time variable is not a Yes, and "here" stops at this repo** — § *Conditional rows* owns both, with `BIRKO_SRC` as the worked example. Present → **leave it**; whether it still lists the right variables is content, not shape. |
| `Dockerfile` (+ `.dockerignore`) **(conditional — is anything here deployed as a running service?)** | [[new-project]] seed | Yes → absent is **missing**, offered and never forced. No — a library, a CLI, a desktop app — → **not applicable**. Cannot tell → **unknown**, resolved in step 2's round. Present → **leave it.** Where a stack scaffolder documents its own Docker pattern, that pattern owns the shape and this row only asks whether one exists. |
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

### A named declaration is not a version — and the survey owns it

The deferral above is about an artifact's **version**, and it must not be read as covering a
**declaration**. The two are different objects, and conflating them left `integration:` with no owner
at all — three steps each handing the question to another, which is TASK-035's whole subject.

| | A version | A named declaration |
|---|---|---|
| The question | *does this artifact match the shape its owner writes today?* | *is this specific field in this specific file?* |
| Who can answer from outside | **nobody** — you would have to know the whole current template, which is the owner's knowledge | **anybody with a grep** |
| Who owns finding out | the owner verb, at the delegation | **the survey**, step 1 |
| What absence means | `present, outdated`, and only once the owner reports the delta | a **choice nobody has made yet**, carried into the one frontier round |

A declaration is as observable as a git remote, and the survey already probes facts of exactly that
kind. Deferring it to the delegation costs the run the only round in which it could have been asked
alongside everything else, so the question either migrates into the fill — breaking the one-round rule
— or falls out of the pass entirely and gets guessed from `git log` later.

**Read which declaration a row needs off the row itself**, never off a list kept here or in a front
door: a row added tomorrow would not be on such a list, and the probe would go quietly narrow. Today
the `tasks/` row is the one that names one.

**A declaration the file already carries is settled — do not ask about it.** That is the whole reason
the probe belongs in the survey rather than in the round: without it the round asks blindly, and a repo
that answered the question months ago gets asked again, on every re-run.

## Lazily-created rows

A row marked **(lazy)** is part of the layer, and **nothing creates it** — not the scaffolder, not
the adopter. The file appears the first time there is something real to put in it, and its owner
decides when that is.

**Why, since every other row is created on sight:** an empty instance of a lazy artifact is not a
neutral placeholder, it is a **claim**. An empty `docs/glossary.md` says the vocabulary was examined
and found thin; an empty `docs/adr/` says nothing here was hard to reverse. Both are false in a young
repo, and both are the kind of false that stops anyone looking again. [[domain]] carries that
argument; the row only has to stop both front doors seeding one.

So absence is the **expected** state of a lazy row, which is why § *Detect what the repo has* gives
it a state of its own — `not applicable yet` — instead of `missing`.

## Conditional rows

A row marked **(conditional)** is part of the layer for **some projects and not others**, and it names
its own condition. Where the condition does not hold, the honest state is **not applicable**, and the row
is reported that way rather than quietly dropped from the survey.

**The condition is not always the kind, and assuming it is was a real defect.** `.env.example` and
`Dockerfile` turn on the project kind; `LICENSE` turns on **licensing posture** — a proprietary service
and an open-source service are the same kind and want opposite answers. A marker that said
*kind-conditional* invited an agent to reach for the kind, get "library", and report an unlicensed
open-source library **not applicable** — laundering away the single gap this section was written for.
Each row therefore states the condition it turns on, and the evidence that settles it.

**Why they are rows at all, rather than left to the scaffolder:** the alternative was to keep them out
of this inventory on the grounds that they are conditional — which is what the file did until
2026-09-01, and it made the opening claim above false by three artifacts. **The cost was one-directional
and that is what made it a defect rather than an untidiness:** [[adopt-project]] walks these rows and
nothing else, so it could never notice a repo with no `LICENSE`. An artifact the scaffolder creates and
the adopter cannot see is a gap that only ever appears in greenfield repos.

**Why not plain rows:** a plain row means *absent ⇒ missing*, so adoption would report a missing
`Dockerfile` on every CLI and every library — a false gap on the majority of real repos, and the fastest
way to teach a reader to skim the survey. Measured 2026-09-01 across seven consumer repos: three are
library/CLI shaped and would each have shown two false gaps on their first run.

**`not applicable` is not `not applicable yet`.** The lazy rows above are *waiting*: the artifact may
appear the moment there is something to put in it, and the state says so. A conditional row whose condition
does not hold is **settled** — a library does not acquire a `Dockerfile` by aging. Reporting either one
as `missing` is the same false-gap error; collapsing the two into one state loses whether anybody should
ever look again.

**Ask the artifact's own question, not "what kind is this repo".** A kind is a label, and the labels run
out: `new-project`'s intake offers *library / service-or-API / web app / CLI / worker / other*, which has no
slot for a **desktop app** — and a real repo declares its kind as *"desktop app + CLI + core library"*, three
at once. Measured 2026-09-01: of three consumer repos surveyed, **all three were compound** — a web app plus
a console importer, an API host plus a frontend, a desktop app plus a CLI plus a library. A row that
demanded one kind would have had to pick one and discard the rest. So each row above asks a question the
repo can answer directly — *does anything here require an environment variable to run?*, *is anything here
deployed as a running service?* — and **any** component answering yes settles it.

**"Here" is the repository being surveyed — the git work tree whose root the survey resolved, and nothing
outside it.** A component in a sibling directory is not evidence, however tightly this repo's build depends
on it. The reason is what the answer is *for*: the layer is per-repo, so a `Dockerfile` a sibling needs is
an artifact nobody adopting *this* repo can supply, and reporting it here produces a gap with no owner.

**This scopes an *obligation*, not every question about out-of-root files — and the difference is load-bearing.**
A conditional row asks *would this repo need us to create X?*, and a sibling's needs cannot create an
obligation here. Other rows ask *does this repo already have a working Y?*, and there a component outside
the root can be perfectly good evidence: the test-harness row says `*.Tests` files count **anywhere** and
calls sibling `X.Tests` projects *the* .NET convention, which is deliberate — a parallel test tree this
repo's own solution registers **is** this repo's harness, and reporting it `missing` would invite
[[populate-tests]] to wire a second runner over a working one. So the rule is: **an out-of-root component
never creates an obligation, and may still evidence a capability.** A drill runner hit the two sentences
together, spotted that this one is scoped to conditional rows while the harness row's own word is
"anywhere", and resolved it correctly to `present, elsewhere` — but it had to reason it out, which is what
this paragraph removes.

**This is a different question from § *CI a repo cannot pass*, and the two must not be collapsed.** That
section asks whether a build input is **obtainable** on a runner, and answers *blocker* for a path escaping
the repo root. This one asks whether an out-of-root component **counts as evidence** about the layer, and
answers *no*. The same fact — a sibling source tree — is therefore load-bearing there and irrelevant here.
Measured 2026-09-01 on an aggregator repo whose root holds only `docs/` and `tasks/` while its solution
registers 343 projects, every one in a sibling git repo: its runner scoped "here" to the adopted repo,
reached the right states, and said *"nothing in the instructions settles whether an aggregator surveys its
aggregate."* It was deciding, not reading.

**A repo with no components of its own answers *no*, and that is settled rather than `unknown`.** Nothing
that does not run can read runtime config, and nothing without an entry point is deployed — so the
evidence **determines** the answer instead of merely being consistent with several, which is the test
§ *A derived state must never be cached as a decision* sets in the consuming project's guide. Do not read
"no source to inspect" as "cannot tell": that is the route by which an aggregator's correct
`not applicable` would become an `unknown` and a question nobody can answer.

**The condition means *requires*, not merely *reads* — the row's own definition says so and the question did
not.** `.env.example` is *"the documented, valueless template of **required** env vars"*, so an optional
override with a committed default needs no template and does not trigger the row. Measured 2026-09-01 on a
web app that reads three runtime environment variables — a framework environment selector, an app-specific
seed toggle documented in a comment, and a test base URL written `?? 'http://localhost:5170'` — while
booting correctly with **none** of them set, because every value lives in committed `appsettings*.json`.
Read as *reads*, the row triggers and reports a missing template for variables nobody must supply; read as
*requires*, it is `not applicable`. Its runner spotted the mismatch between the condition and the
artifact's own definition and had to reason past the text to resolve it, which is what this paragraph
removes. **Ask: would a new contributor be unable to run this without being told a value?**

**A build-time environment variable does not satisfy the condition either.** The
question is whether a **running** process needs its configuration from the environment; a variable consumed
by the build system — a path locator, a toolchain switch — is not that, and `.env` files are not how a
build reads one. Worked example: every repo in this fleet reads `BIRKO_SRC`, an MSBuild property resolving
the framework checkout, and none of them has runtime environment config at all. **Three separate drill
runners each derived this from scratch and each logged it as an inference**, one adding that *"the row does
not distinguish build-time from runtime env vars in so many words"* — a rule three readers must each
reconstruct is a rule that is not written down, and the fourth is the one who reports a
`missing .env.example` on a desktop app that has no runtime configuration.

**Kind is evidence toward that question, and a declaration beats a signal.** Read the kind where the repo
states it: `new-project` knows it because intake asked, and a repo already carrying an agent guide often
declares it outright — which is the consuming project's own *read the declaration, never infer it* rule
applying here. Only where nothing declares it do you fall back on signals: a listening port and an entry
point say service; a console entry point or a `bin` mapping with no server binding says CLI; a published
package manifest with no host says library; a long-running entry point with neither says worker; a
windowing/UI toolkit dependency with no server binding says desktop.

**Treat signals as evidence, never as an answer.** They are *consistent with* several readings — a library
shipping a sample server, a CLI that also serves — which by § *A derived state must never be cached as a
decision* in the consuming project's guide is the shape that **had to be declared**. So where they conflict
or run out, the state is **unknown**, the row names the fact that was missing, and step 2's question round
settles it alongside the other choices. Do not default to *not applicable*: that is the reading which makes
a real gap disappear. Measured on the same three repos — one had no licence evidence in any direction and
correctly landed `unknown`, while another was settled `not applicable` by one line in its README. The
difference between those two is the whole point of the state.

## A guide's vintage is not surveyable

The agent guide is the artifact the layer grows fastest, so *"this guide is a 2026-08 vintage and the rules
have moved on"* is the single most valuable thing an upgrade run could report. **It is also the one thing
this survey must not attempt**, and saying so plainly is better than leaving a gap that looks like an
oversight.

**Measured on `WorkoutTracker`, 2026-09-01:** 342 lines, every one of the seed's `##` sections present, and the task-first
gate, `/verify-conventions` in the close gate, *generated files are owned by their verbs* and *status
changes go through their verbs* all absent. It is genuinely an older vintage, it surveys as `present`, and
that is the correct answer for reasons that only appear when you try to build the alternative.

**Why a rule-list diff against the seed does not work — attempted, measured, rejected 2026-09-01.** The
seed carries named rules, so "which of these is absent?" looks like a list-membership test rather than a
judgement. Three measurements say otherwise:

- **It is a check for the shape we would have made**, which is what this file's own § *Detect what the
  repo has* forbids by name. `Symbio`'s guide is a 239 KB Slovak document with **40 `KRITICKE` rule
  sections and 345 mentions of tasks**; a membership test for four English phrases reports it missing all
  four and offers to append them. A repo stating the same rule *in its own words* is the normal case, not
  the exotic one.
- **The negative control fails.** This repo's own `AGENTS.md` — current, dense, the thing an upgrade run
  must **not** flag — omits two of the seed's named items. The test flags the guide it was built to leave
  alone.
- **The inventory is not reproducible.** The seed's `### Working rules` holds **eight** bullets, plus the
  skills its close gate names; two runs picking different subsets produce different "missing" lists, so
  the state fails its own test — *could you write the missing items down before looking at the repo?*

**So the honest outcome is a limitation, and the advertising now matches it.** The skill's description says
the upgrade path reconciles the layer's **shape**, not the currency of anyone's prose. Report the guide
`present`, name any missing `##` section — § *Matching a guide's sections* owns the inventory and the
by-meaning rule, and explains why a section diff is allowed where this rule-list diff was not — and leave
the rules inside alone. **What a reader gets instead**
is [[verify-conventions]], which lints real diffs against whatever the guide records — so a rule the guide
never adopted shows up the moment code contradicts it, judged against that project's own rulebook rather
than against ours.

## Covered means covered in the repo

Wherever a row asks whether something is *covered* — today the `.gitignore` row's `.env` / `.env.*` and
agent-tool local state — the question is **which file carries the line: the repo's own, or the machine's**.
The repo's own counts. A user-level or global ignore does **not**, however genuinely it works right now.

**Whether that file is committed yet is a different question, and the two compose.** A repo's `.gitignore`
carrying the right lines but never landed is **covered *and* `present, uncommitted`** — per
§ *Detect what the repo has*, tracking is orthogonal to the row's own content check, so report both rather
than letting either answer suppress the other. Reading "covered" as "committed" would double-report a
single gap and, worse, would tell a developer their lines are wrong when what is missing is the commit.

**The reason is the row's entire purpose: the next clone.** A global ignore lives in one developer's
`core.excludesFile` and travels nowhere. The repo it protects today ships without that protection, and the
person it fails is whoever clones it next — which is exactly who the row exists for. So a survey that
accepts a global hit inverts the row rather than merely being lenient.

**This makes the obvious probe the wrong one.** `git check-ignore <path>` answers *"is this ignored on this
machine"*, which is not the question. Use `git check-ignore -v <path>` and read the **source** it names:
a line in the repo's own tracked ignore file counts, anything under the user's home or global config does
not. Measured on a real consumer repo: `.claude/settings.local.json` came back ignored, sourced from
`~/.config/git/ignore`, while `git ls-files .claude` was empty — the file was genuinely unprotected in the
repo and genuinely ignored on that machine, and only the `-v` source distinguishes the two.

**Report it as a gap and offer the line, saying that nothing is currently at risk.** Both halves matter:
the gap is real for a clone, and a reader who is told they have a problem they cannot reproduce locally
stops believing the survey.

## Matching a guide's sections

The guide row asks which of the seed's `##` sections a repo's guide is missing. Two things make that
answerable, and leaving either unsaid is how a survey reports a guide complete when it is not.

**The inventory is the seed's own headings** — [templates/CLAUDE.seed.md](templates/CLAUDE.seed.md), whose
`##` headings *are* the list. Read them off that file every run; do not keep a copy of them here, in a front
door, or in a survey's prose. **Read each section's body too, not only its heading** — matching by meaning
means asking what question a section exists to answer, and a heading alone does not say. Two drill runners
reached for the bodies unprompted and one said so outright: *"matching by meaning is impossible without
knowing what question each heading covers."* A copy goes silently wrong the day the seed gains a section, and the survey
would then report a guide complete against a list one section short — the failure this section exists to
prevent, arriving by the tidy route. **Measured 2026-09-01: nothing in the survey's reading set named this
file at all**, and one cold runner reached into it uninstructed while another projected that a run which did
not *"would report the guide `present` with no missing sections named"* on a repo whose guide was missing the
one section explaining the 18 features it already kept.

**Match by meaning, never by heading text.** A repo states the same thing in its own words and its own
language, and § *Detect what the repo has* forbids checking for the shape we would have made. So:

| Seed section | What decides whether a guide answers it |
|---|---|
| `## Conventions` | **[[verify-conventions]] § *Finding the rulebook*'s ladder owns this one** — do not write a second test. `INFER.md` already defers to the same ladder, so all three skills agree on what a rulebook is. |
| every other section | *Does the guide answer the question this section exists to answer?* — not *does a heading resemble ours*. |

**Why this coarse test is allowed where § *A guide's vintage is not surveyable* rejected a finer one.** That
section measured a **rule-list** diff against the seed and rejected it on three grounds. A **section** diff
survives all three, and the difference is granularity rather than luck:

- **The negative control passes.** The rule-list test flagged this repo's own current guide, which is the
  thing an upgrade run must leave alone. On sections, that guide answered **every section the seed carried
  when this was measured (2026-09-01)**, and so did `WorkoutTracker`'s. *The score is deliberately not
  written as a number here:* a count is exactly what the pointer above exists to avoid, and a reader who
  trusts a stale one stops checking the sections added since. Measured instance — a drill run against a
  five-section seed met "4 of 4" in this very paragraph and had to choose between the number and the
  instruction; it chose the instruction and reported *"had I trusted the number, the fifth would never
  have been checked."*
- **The shape-we-would-have-made objection is real, and by-meaning matching answers it.** `Symbio`'s guide
  is 19 `##` sections of Slovak with **not one** matching a seed heading by text — a text match reports all
  four missing, which is precisely the rejected behaviour. By meaning it resolves three (`Architektura —
  vrstvy`; the `smerovnik` router plus eleven `Pravidla … (KRITICKE)` sections; `Dev tools`) and leaves one
  honest judgement.
- **Four whole topics are reproducible where eight-plus named rules were not.** *Does the guide answer this
  at all* has one answer per section; *which of these rules is absent* had two runs producing two lists.

**Where the meaning-match is genuinely ambiguous, name it in the report — never decide it silently.**
The coarse test removes most of the judgement, not all of it: on `Symbio`, three sections resolve cleanly
and whether `Ako pouzivat s AI agentom` answers the lifecycle section is a real call. Report that one as
*undetermined, and why*, and let step 2's round settle it — the same treatment a conditional row's
unsettled condition gets. A silent yes appends nothing and hides a gap; a silent no offers to append a
section the guide may already answer, and neither is recoverable from the table.

**A guide whose rules are woven through it rather than sectioned is not missing `## Conventions`.** That is
the ladder's own rung 4, and it matters here because the row's remedy is to *append*: appending a
`## Conventions` block to a guide that already states its rules elsewhere in itself creates a second home
for rules, and the next task gets to pick which one wins. Answered is answered, wherever it sits inside the
guide.

**A section whose content lives in another file is `present`, and the report says where.** Measured:
`BardStudio`'s guide has no `## Commands` counterpart while its `README.md` §§ Build / Run carry exactly
that content. Reporting it missing would offer to append a second copy of something the repo already
documents, which is the false-`missing` this file calls the dangerous direction — and *"a repo that solved
it differently has solved it"* is the standing rule. **`## Conventions` is the one section with a narrower
test**, and the test is **reachability from the guide**, not residence in it. [[verify-conventions]] reads
the guide at every gate *and* — by its own § *Finding the rulebook* — *"any project-specific checklist the
guide links to"*. So rules in a **companion the guide links** are enforced and count as answering; rules in
a file nothing links, or in a `README.md` the ladder never treats as a rulebook, are not reachable by the
thing that enforces them and do **not** count. Flag that case loudly, as the row says.

*Stated this way because the two readings collide and one is wrong.* An earlier wording said the guide must
carry its conventions **itself**, which contradicts § *Location is orthogonal too*'s rule that a linked
companion is part of the one artifact — and a drill runner hit both sentences together on a repo holding
fourteen UI rule sections in a linked companion. It resolved the case only because that guide *also* carried
forty rule sections of its own, and said so: *"had the rules been only in the companion, the two sentences
would genuinely conflict and the text does not say which wins."* Reachability is what both sentences were
reaching for.

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
| Test harness | **what the gate actually runs** — read the CI workflow (or task-runner target: a `Makefile`, `justfile`, `package.json` script) and see what it invokes; a repo's suite is whatever its gate executes, whatever the file is called. Then a test runner in the manifest (xunit, vitest, pytest, `go test`); then `*.Tests`/`*_test.*`/`*.spec.*`/`*Test*.cs` files **anywhere**; then a runner config. Sibling `X.Tests` projects are *the* .NET convention — a missing `tests/` folder means nothing on its own |
| Rulebook | whatever [[verify-conventions]]'s ladder accepts. The two skills must agree on what a rulebook is, rather than each guessing separately |
| Docs | `docs/` is a convention, not a requirement — architecture notes may live in the README, a `wiki/`, or `Documentation/` |
| Changelog | `CHANGELOG.md`, but equally `HISTORY.md`, `NEWS.md`, or a releases section in the README |
| Task tracking | `tasks/`, but a repo may track work in GitHub Issues or Jira alone — that is *tracking*, not an absence |

**Why the test-harness row leads with observed execution rather than a name.** The other three entries are
**declarations of intent** — a manifest says a runner *should* exist, a filename says a file *is* a test.
Reading the gate is **observed execution**: if CI invokes it, the suite exists, whatever anyone called it.
That direction cannot false-positive, which is why it goes first.

It is also the entry whose absence produced the worst possible instance. **Measured on this repo, 2026-08-23:**
no manifest, and `.github/workflows/skills-lint-test.sh` matches **none** of the four globs — hyphen-`test`,
not underscore; `.sh`, not a test extension. Applied literally the ladder returned **`missing`** for the test
harness of the repo that *defines the ladder*, with a 36-case suite that CI runs before every lint. That is
the **false `missing`** this whole section calls the dangerous direction — fill acts on the survey, so
`missing` would have invited [[populate-tests]] to wire a runner over a working suite.

**The generalisation is deliberate, not a glob bolted on for `.sh`.** What the new entry covers is *any*
project whose checks are invoked rather than named — shell suites, `Makefile` targets, `just` recipes, npm
scripts, a compiled test binary called from CI. Adding `*-test.sh` to the glob list would have fixed this
repo and left the next non-conventional stack to rediscover it.

**Report the state precisely.** The distinctions matter, the number of them does not — this list
grows as real repos turn up conditions it cannot yet express:

- **present** — found where expected, and (in a git work tree) fully tracked.
- **present, uncommitted** — found on disk, but git does not have all of it. **Only meaningful inside a git work tree**: in a directory with no repo yet every path is untracked, which is what the `git init` offer is for, not this state. Probe with `git status --porcelain --untracked-files=all -- <path>` (`--untracked-files=all` matters: plain `--porcelain` collapses an untracked directory to `?? docs/specs/` without naming the member, and the member is the thing you have to offer to land).

  **Read the result as a rule, never as a list of line prefixes: the artifact is on disk *and* the probe prints anything ⇒ this state.** Porcelain is two columns — **XY**, X the index and Y the work tree — so every *list of shapes* written here has been one column short: `??` (untracked) and ` M` (tracked, modified, unstaged) are the *unstaged* half only, while a pass that wrote the layer **and staged it** prints `A ` for a new file and `M ` for an amendment, matches neither, and is reported plain `present`. Measured 2026-08-31: `A  tasks/config.yml`, `M  README.md`. (A staged **rename** shows as `R  old -> new` when the pathspec is the *directory*; probed by the new member's own path it is an ordinary `A `. Which one you see is a property of the pathspec, not of the change.)

  **Two output kinds are *not* this state, and both must be excluded by name** — this is what the presence conjunct above is for, and dropping it is how a widened rule turns destructive:

  | Output | Why it is not `present, uncommitted` |
  |---|---|
  | a **deletion** — `D ` (staged) or ` D` (unstaged) | the path is going away, not sitting unlanded. For a *directory* artifact a staged member deletion prints `D  tasks/.config.yml` while `tasks/` itself is still on disk, so without the conjunct the row reads `present, uncommitted` and the offer to land **commits the removal** — under a message claiming to protect an artifact the next clone would not have. Verified 2026-08-31. |
  | an **unmerged** path — any `U` in either column (`UU`, `AA`, `DU`, …) | a conflict in progress. Nothing should offer to commit one, and the user is mid-operation |

  The shapes stay worth knowing as **illustrations, never as the rule** — the untracked member is what matters most for the layer's *directory* artifacts, where a pass may have committed `tasks/README.md` and left `tasks/.config.yml` behind; the tracked-but-uncommitted amendment is the more common one on the upgrade path, since a pass that appended `## Conventions` to an already-tracked guide leaves nothing untracked at all. (`git ls-files -- <path>` answers "is any of it tracked", a different and useless question here; `git ls-files --others` sees that amended guide as a clean repo and loses the work just as quietly.)

  **The git-ignored carve-out holds for free**: an ignored path produces *no* output, so it falls through to plain `present` with no exception written for it. **The no-repo carve-out does not, and must be checked explicitly.** It is tempting to say the probe simply fails outside a work tree — it does in a bare directory, printing nothing to stdout — but the case this pair actually meets is a directory **captured by an ancestor repo**, where `git rev-parse --is-inside-work-tree` says `true` and the probe happily prints `?? subproject/CLAUDE.md` for every layer artifact. Reported as this state, adoption would offer to land the whole layer **into the ancestor's** history. So compare `git rev-parse --show-toplevel` with the directory being adopted: equal ⇒ this state is meaningful; an ancestor ⇒ it is not, and [[adopt-project]]'s surface-the-resolved-ancestor offer owns the case, because only the user knows whether that ancestor is intended. Verified 2026-08-31. This state is normally an earlier adoption pass that wrote files and stopped before committing — *the* reason someone re-runs an idempotent adoption, so it belongs on the main path. Reported as plain `present` it hides an artifact the next clone will not have and the next pass will write over, so **offer to land it** instead of counting it done.
- **present, outdated** — there, but in an earlier version of its own shape: a config missing a field the current template has. **Claim it only where something can tell you** — a row whose *already present?* column names a verb, whose delta then *is* the evidence. Where nothing can answer (an agent guide missing a section, whose shape no init owns), the honest label stays `present` with the gap named: reading a schema and judging someone's prose are not the same act. It **composes** with `present, uncommitted` rather than competing — a config that predates a field *and* was never committed is both, and the report says both. Observed in `Presenter`, whose `tasks/.config.yml` predates the `integration:` field: surveyed `present` from the outside, skipped as "already skill-shaped", and the missing field then inferred from `git log` instead — see § *Delegation follows the row, not the artifact's appearance*.
- **present, elsewhere** — found at another **path**, under another **name**, or inside another **file**. **Say where.** Never silently relocate it, and never offer to create a second one. **Any deviation from the row's canonical path or name lands here** — see § *Location is orthogonal too*, which also settles that this composes with every row rather than only the ones whose cells mention it.
- **unknown** — you could not determine it. Honest, and it stops the fill. **Name what was missing, and say which kind of missing** — evidence, or the rule itself. See § *Two things reach `unknown`*.
- **missing** — you actively looked and it is genuinely absent.
- **missing, not offered** — genuinely absent, and the skill has decided **not** to offer it; the reason travels as part of the state (the CI case below is the standing example). Distinct from plain `missing` because the absence is *adjudicated* rather than merely observed. **The adjudication is re-derived from its evidence on every run, never remembered** — nothing persists it and nothing needs to: the survey and the report are stdout, and the evidence (below) is cheap to re-read. So the moment the evidence changes, the offer comes back on its own, with no bookkeeping. What the state suppresses is the **offer**, not the check and not the status line: re-deriving costs nothing, printing one line of status is not a question, and re-asking *"shall I add this?"* every run is the only thing that was ever the annoyance. A derived state cached as a decision can never expire — which is this rule's own mirror of § *Read the declaration, never infer it* in the consuming project's guide.

- **not applicable** — a **conditional** row (§ *Conditional rows*) whose condition does not hold for this project: a `Dockerfile` in a CLI, an `.env.example` in a library, a `LICENSE` in a proprietary repo. **Settled, not pending** — unlike the state below, nothing will change it, so it suppresses the fill, the offer, and any later re-ask. Claimable only where the row declares itself conditional **and** its condition was actually settled by evidence; where the evidence ran out the state is `unknown`, naming what was missing, because defaulting to this one is how a real gap is laundered into a design choice.
- **not applicable yet** — a **lazy** row (§ *Lazily-created rows*) with no instance, in a repo that has nothing to record. **This is not a gap and is never reported as drift.** It suppresses both the fill *and the offer*: asking *"shall I create a glossary?"* is how the empty file the lazy rule exists to prevent arrives **with** the user's consent instead of without it, so the offer is the defect here, not the fill. **Claimable only where the row declares itself lazy** — an absent artifact whose row creates it is `missing`, and relabelling it here would launder a real gap into a design choice, which is the false-`present` failure pointing the other way. Distinct from `missing, not offered`: that is a genuine gap *adjudicated* unfillable for now, so its offer returns when the evidence changes; this one has nothing to fill and no evidence that could change.

*"I could not tell"* is a legitimate answer; *"you don't have it"* when you merely failed to look
properly is a lie that invites a destructive fill. When in doubt, report **unknown** and ask.

**Tracking is orthogonal to the *Already present?* column.** That column decides what to do with an
artifact's **content** — leave it, merge into it, delegate to its owner — and a row reading
*"Present → leave"* still leaves it: landing an untracked file changes nothing inside it. So
`present, uncommitted` adds the offer to commit **on top of** whatever the row says, and never
overrides it. Without this line the two instructions read as a contradiction, and the row wins,
which is how the artifact stays out of history. **Composed, but ordered** — where the row's content
action *rewrites* the file rather than leaving it (a generated artifact whose owner verb gets re-run),
the commit happens first, since that is the only order in which a mistake survives. [[adopt-project]]
step 3 owns that rule and its reason; this is the pointer, not a second copy.

**Location is orthogonal too.** Exactly as tracking is: the *Already present?* column decides what to do
with an artifact's **content**, and *where* the artifact sits is a different axis. So the location states
compose with **every** row — conditional or plain — and a row whose cell never mentions them still gets
them. Without this line each row cell would have to enumerate them, which is the restated-list defect, and
the rows that forgot would silently report `missing`.

**Measured across three row kinds, by four independent runners:** a conditional row's artifact at another
**path** (`deploy/Dockerfile` rather than root); a conditional row's artifact under another **name**
(`License.md` rather than `LICENSE`); and a **plain** row's artifact inside another **file** (architecture
notes living in the agent guide and README, with no `docs/architecture.md`). The plain-row case is why this
is stated here rather than in § *Conditional rows* — the gap was never specific to them.

**A deviation in name lands in `present, elsewhere` just as a deviation in path does, and this had to be
decided rather than left open.** Two runners met the same `License.md` and split: one reported
`present, elsewhere` naming the file, the other reported plain `present`, reasoning that the file is in the
expected *location* and differs only in name — and said outright that *"the text does not draw"* that
distinction. Both reasoned soundly, which made the survey non-reproducible on that row. **The tie is broken
by what the state is *for*:** its load-bearing half is *never offer to create a second one*, and a repo with
`License.md` is exactly a repo that must not be offered a `LICENSE`. Plain `present` carries no such guard,
so it loses the only consequence that matters. Directory depth was never the question.

**"Inside another file" means the artifact's *purpose* is served there, not that its subject is mentioned.**
Prose describing what an artifact would contain is not that artifact: a deployment guide naming a required
environment variable, with a recipe for generating it, does not stand in for the valueless template a
contributor copies. Such a row is **`missing`** — and the report **says where the fact is already
documented**, so the fill adds the artifact without duplicating the explanation. That last clause is the
point: the *never offer a second one* guard is what tempts the other reading, and it is satisfied by
reporting the location rather than by mislabelling the state. A drill runner reached exactly this fork and
named it: *"the text does not settle which wins when another file documents the **fact** but not the
artifact's **form**."*

**A guide that delegates to sibling files is one artifact, not several.** The agent-guide row names the
canonical entry point (`CLAUDE.md`, or `AGENTS.md` + bridge); files that entry point **links** —
`CLAUDE-maintenance.md`, `CLAUDE-projects.md` and the like — are part of the same artifact, not extra rows
and not `present, elsewhere`. They are where a section's content may legitimately live, which
§ *Matching a guide's sections* already allows. Two measured instances had four and two such siblings, and
a survey that treated them as unclassified would either ignore rules the repo really has or offer to append
sections it has already written down. **Classified by existence and role, never by quality** — whether a
companion's prose is current or good is content, which § *A guide's vintage is not surveyable* excludes; a
companion is part of the artifact because the entry point links it, not because it reads well.

**The link is what makes it a companion — a shared name prefix does not.** A `CLAUDE-*.md` the entry point
links from nowhere is **not** part of the guide: it is a separate document that happens to share a prefix,
and the survey neither folds it into the guide row nor reports it as a gap. Measured on the same repo: of
four `CLAUDE-*.md` files beside the guide, **three are linked** from it (a routing table sends UI work and
new-module work to two of them, and a documentation index names a third) and **one is not** — a
copy-paste prompt template for humans, referenced by nothing. Treating it as part of the rule surface
because of its filename would have the survey judging a document the guide never adopted; treating its
absence of a link as a defect would invent a requirement nobody stated. **This branch is stated because the
rule above is otherwise silent on it**, and silence is how the fourth file stayed unclassified while the
other three were resolved.

**Two things reach `unknown`, and only one of them is ignorance.**

| | **Evidence ran out** | **The rule ran out** |
|---|---|---|
| What happened | the survey could not find the fact | the survey found **every** relevant fact and the row still does not say which side they fall on |
| Who can resolve it | the **user**, in step 2's round | **nobody in this repo** — the row needs amending |
| What the report owes | the fact that was missing | the facts you *did* gather, and what the row fails to decide about them |

**They are the same state and different findings, which is why this is a reporting rule and not a ninth
state.** The artifact's condition is identical in both — the survey cannot say — and a state describes the
artifact, not who can fix it. The list is already eight states an agent picks exactly one from, and adding a
label that does not describe the artifact would make that branch worse while answering a question about
routing. `unknown` already requires naming what is missing; this only says that when the named-missing-thing
is **the row itself**, the finding goes somewhere else as well.

**A rule-ran-out `unknown` is a defect in the layer, and the layer is not the adopted repo's to fix.**
Report it to the user as a finding against these instructions — naming the row, the evidence gathered, and
the question the row leaves open — and **do not file it into the adopted repo's tracker**: [[adopt-project]]
§ 3b files defects belonging to *that* repo, and a row that cannot decide belongs upstream, exactly as
[[fix-next]] § *Fix at the right layer* sends a symptom here to the defect there. Sending it to step 2 alone
is the failure this rule exists to stop: the user answers, the run proceeds correctly, and the row stays
broken for the next repo with nothing anywhere recording why.

**You may only claim the second kind if you can say what you read.** A runner who stopped looking and a
runner who read everything both feel certain, and only one of them is entitled to blame the rule. So the
claim requires the gathered evidence *in the report*; without it the state is plain `unknown` and the round
asks. Measured: the runner that produced this distinction had grepped every config source and every
environment read in the repo before saying *"no fact is missing here… what is unsettled is the row's own
boundary, not my knowledge."* That is the bar — an enumeration, not a feeling.

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
that could run it fine. (Written down because counting `..` is the obvious implementation and it is
wrong — it over-reported on the first repo it met.)

**A variable in the path is not the test either — obtainability is.** Ask: *can the repo tell a runner
how to get the target?* A restore feed can; a developer's sibling checkout cannot. So an unresolvable
path blocks CI only when nothing in the repo would put the target on the runner:

| Target | Runner obtains it? | Blocks? |
|---|---|---|
| `$(NuGetPackageRoot)…` | yes — `dotnet restore`, which is the workflow's own first step | **no** |
| `$(MSBuildExtensionsPath*)`, `$(MSBuildThisFileDirectory)`, `$(MSBuildProjectDirectory)`, `$(MSBuildSDKsPath)` | yes — the SDK defines them | **no** |
| `$(BirkoSrc)`, `%SOME_SRC%` — a sibling source tree named by an env var | no | **yes** |
| a relative path resolving outside the repo root | no | **yes** |

Judge an unfamiliar variable by the question, not by whether it appears above. **And never scan `obj/`
or `bin/`** — they are build output, not source manifests: `obj/*.nuget.g.props` is written *by* restore
and is full of `$(NuGetPackageRoot)` imports that mean nothing about isolation.

(Measured on `Symbio`, a real consumer: applying the old blanket clause over
`*.props`/`*.csproj`/`*.projitems`/`*.targets` gave **318** variable-rooted hits; excluding build output
and obtainable variables left **99**, every one of them the genuine `$(BirkoSrc)`. The 219 difference is
why this is spelled out. The false negative was measured too, and it is cheaper to trigger than it
looks: a plain `dotnet new console` plus **one** ordinary package reference
(`Microsoft.Extensions.Configuration.UserSecrets`) is enough — restore then writes an
`<Import Project="$(NuGetPackageRoot)…buildTransitive…props">` into `obj/`, and the old clause denied that
repo a workflow it would have passed. A *bare* console app with no packages does not trigger it, which is
exactly why eyeballing a trivial fixture would have missed this. That is the false negative on CI, the
direction this whole section exists to avoid.)

**Other ecosystems: unverified.** The `Cargo.toml` `path =`, `package.json` `file:` and editable-install
cases above are resolvable paths, so the obtainability test applies to them unchanged. Whether those
ecosystems have their own *obtainable-variable* equivalents has not been measured on a real repo — treat
it as unknown rather than assuming they do or don't.

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

Ground truth and the agent guide first (later steps read them), then **`docs/features/`**, then
`tasks init`, then `specs init` — the spec map wants the guide's architecture vocabulary, and
`/tasks init` may need the task mode the guide records.

**`docs/features/` before `tasks init`, not after**, because `tasks/README.md`'s content depends on it:
[[tasks]] `triage` renders a feature-aware slice and a drift callout **only when `docs/features/`
exists**, so a dashboard generated first is stale the moment the folder appears. `new-project` already
does this in bullet order; recording it here is what makes it true for the adoption path too, and stops a
later reordering from silently reintroducing it. (Where an ordering cannot be arranged — an artifact
created after its consumer — [[adopt-project]] § 3c re-runs the owning verb instead; ordering is the
cheaper guarantee, so prefer it.)

## Rule

**Never overwrite a file the repo already owns.** A conflict is reported for the user to resolve,
never resolved silently. An adoption that quietly rewrites someone's work is worse than one that
does nothing, because it destroys the thing it was meant to preserve.
