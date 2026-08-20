---
name: adopt-project
description: Bring an EXISTING repo onto the project lifecycle layer — survey what it already has, fill only what is missing, and report both. Use when the user says "adopt this repo", "adopt-project", "set up the lifecycle here", "add tasks/docs to this project", "init the skills in this repo", "we already have code, wire up the lifecycle", "rescan this project", "bring this repo up to date with the skills", "adoptuj projekt", "nastav lifecycle v tomto repe", "doplň chýbajúce časti", or points at a codebase that does not yet use these skills. Also the UPGRADE path — re-run it whenever the universal layer grows, to reconcile a repo that adopted an older version. Tech-agnostic. This is the brownfield counterpart to [[new-project]] (greenfield): same layer, opposite starting point.
---

# adopt-project

The **brownfield front door**. [[new-project]] creates the universal layer for a repo that has
nothing; this reconciles a repo that already has code, history, and opinions of its own against
that same layer — see [LAYER.md](../new-project/LAYER.md), the single definition both skills work from.

**One skill covers both cases**, because they differ only in how much is missing:

- *"We have code and none of this."* — first adoption.
- *"We adopted this months ago and the layer has grown since."* — the same run, fewer gaps.

So it is **idempotent by design**: re-run it any time. Nothing is ever overwritten and nothing is
written unasked — but *idempotent* is not *read-only*: a repo with nothing **missing** can still have
an artifact landed (present on disk, never committed) or reconciled by its owner (present in an older
shape). A re-run that finds neither writes nothing at all.

## What it does not do

It does not reimplement file shapes. Each artifact is created by the skill that owns it —
[LAYER.md](../new-project/LAYER.md)'s **Owner** column is the list ([[tasks]] `init`, [[specs]]
`init`, [[populate-tests]] `adopt` among them), and those skills are already delta-based and safe
to re-run. This skill decides *what is missing and in what order*, then delegates. Hand-rolling
those shapes here is how the two versions drift.

## Process

### 1. Survey — read before writing anything

Walk [LAYER.md](../new-project/LAYER.md) and classify every artifact by the states its
§ *Detect what the repo has* defines — that section is the definition and carries the evidence to
check per row. The states are deliberately **not** listed here: the list grows whenever a real repo
turns up a condition it could not express (it has grown twice already), and a copy here goes wrong
silently the next time, with nothing to signal it.

These consequences decide behaviour:

- **When in doubt, `unknown` — never `missing`.** A false "missing" invites a fill that writes over
  a working setup, which defeats the never-overwrite rule from underneath instead of breaking it.
- **Present but thin is `present`, with the gap named** — an agent guide with no `## Conventions`
  block, a `tasks/` tree with no `.config.yml`. The artifact is there; report what it lacks.
- **From outside you cannot see a version.** An artifact another skill owns may be present in an
  older shape than the layer now expects — a config written before a field existed looks complete
  from the outside. Where the artifact's row names a verb, step 3's delegation is what answers, so
  leave the version question to it rather than guessing here; where no verb owns the shape, the
  thin-but-present rule above is the whole answer (see [LAYER.md](../new-project/LAYER.md)
  § *Delegation follows the row, not the artifact's appearance*).

Alongside it, detect the facts the fill will need: the stack (manifests, source layout), whether a
test runner already works, whether a git remote exists, whether the repo is captured by an
ancestor git repo, and whether anything the layer owns is sitting on disk **untracked** — the
signature of an earlier pass that wrote and never committed.

**Print the survey as a table and stop.** The user sees the whole picture before a single file is
written.

**A defect the survey turns up does not belong in that table.** It is not a layer row, and the user
needs to see it before deciding anything about the fill. List defects beneath the table and file them
per step 3b — **including when the table comes back complete**, which does not end the run if a defect
is outstanding.

**A repo can only be called complete once the owners have spoken.** Finishing at the survey is right
when nothing is left to ask — but *present* is not *current*, and for any row whose column names a
verb to delegate to, the survey has not established completeness; only that verb can. So a
"complete" table is the end of the run only when **no row names a verb to delegate to, or every such
verb has already answered**. Otherwise continue: step 3's delegations are the rest of the survey, not
extra work beyond it. (Skipping them on a repo whose artifacts are all present is how `Presenter`
kept a `tasks/.config.yml` with no `integration:` field through a full pass that reported it
complete.)

### 2. Infer the conventions, then confirm them

This is the step that makes adoption worth doing. The repo has already answered most convention
questions in its own source — read the answers out and put them to the user **with the evidence
that suggested them**. See [INFER.md](INFER.md) for what to read per subsection, how to tell a
convention from an accident, and how to collect glossary candidates.

**The round is scoped to what the guide does not already answer, and may be skipped entirely** —
`INFER.md` § *When the rulebook already answers it* owns the conditions. A repo whose rulebook
already exceeds the layer gets no proposals, because proposals there dilute a finished guide rather
than filling a gap. **Say when you skip, and name what covered it** — in this step's own output, and again in step 4's
report, which is the part that outlives the conversation. Not in the survey table: coverage is judged
here, after that table has printed. A silent skip is indistinguishable from a skill that forgot the
step, and the user cannot ask for a round they never knew was declined.

Two rules govern it: **propose, never assert** — an unconfirmed inference is dropped, not written
as a guess — and **show the evidence**, so the user can disagree specifically rather than
rubber-stamp.

Alongside the inferences, a few facts are choices rather than observations: task-tracking mode
(local / hybrid), the integration model (`pr-per-task` / `single-branch`), whether the canonical
guide is `CLAUDE.md` or `AGENTS.md` + bridge, and the license posture.

Ask about an artifact the survey found **missing**, or about **a declaration a present artifact
lacks** — a repo that already has a guide is not asked which guide it wants, but a repo whose
`tasks/.config.yml` predates the `integration:` field *is* asked for it, because nothing in the repo
answers and the alternative is guessing from `git log`. Pass the answers to the owning verb
(`/tasks init` takes `mode=` and `integration=`) so nobody is asked twice.

Put the inferences and the choices in **one frontier round** ([[grill-me]]'s shape), not a queue of
single questions. A 15-rule proposal asked one at a time becomes an interrogation, and the answers
stop being considered somewhere around round six.

### 3. Fill the gaps, in dependency order

Follow [LAYER.md](../new-project/LAYER.md) § *Ordering* — later steps read what earlier ones write,
so the sequence belongs to the inventory rather than being restated here. For each artifact follow
its **"already present?"** column in the same file.

The rules that bind the whole step:

- **Never overwrite a file the repo already owns.** Report the conflict; let the user resolve it.
- **Never reconstruct `docs/BRIEF.md`** from an existing README. Stamp the adoption instead (see [LAYER.md](../new-project/LAYER.md) § The adopted-repo brief).
- **An `unknown` row is not filled — ask instead.** The survey never established that artifact was
  absent, so writing it is a guess aimed at the user's own files: the false-missing defect with one
  extra step.
- **Never skip a delegation because the artifact looks right.** Presence decides whether to
  *create*, never whether to *delegate*, and the owner is the only thing that knows its own current
  shape. Skipping one is how `Presenter` kept a `tasks/.config.yml` with no `integration:` field
  through a full adoption pass.
- **Report the outcome the owner reported, not the state you found.** The survey may have recorded
  `present, outdated`; what the report says is what happened to it. Map the verb's answer: *already
  current* → `present`; *brought up to date* → **`amended`**, naming what the owner added — the file
  is current now, so calling it `outdated` states the opposite of the truth, and it is the repo's own
  file that changed, which is precisely what `amended` exists to surface; *created* → created. A row
  stays `present, outdated` only when the reconciliation was **declined or impossible**. Only a verb
  that **cannot answer** — it declined to look, or cannot tell an old shape from a current one —
  leaves the row `unknown`, with that verb named as the reason. Never upgrade silence into a clean
  bill of health, and never downgrade a real reconciliation into "I could not tell".
  - **An `unknown` that came from a verb's silence is report-only** — it is *not* subject to the
    ask-to-fill rule above. The artifact is sitting right there; asking whether to create it is
    absurd, and the honest output is "present, and `<verb>` could not tell me whether it is
    current".
- **A `present, uncommitted` row is landed, not rewritten.** The file is already right; what is
  missing is the commit. Offer it in the adoption commit and report it. Rewriting it discards an
  earlier pass's work to produce, at best, the same bytes.
- **A defect that blocks a delegation is handled at that delegation**, not deferred to the end — a
  broken build stops [[populate-tests]] `adopt` from wiring anything. Step 3b owns the rule and what
  the report then owes.

### 3b. Defects found along the way

Adoption reads a whole unfamiliar codebase, which makes it the highest-yield finder of defects that
have nothing to do with the layer: a path aimed at a directory that moved, a build broken by a
reference nothing declares, a script that cannot have run in months. [[tasks]] § *Findings become
tasks, or they evaporate* governs these, and it governs them **whatever the user decides about
fixing**.

**Filing is not the same decision as fixing.** Offer the fix; the user decides that. The task is not
theirs to decline.

| The user says | What the run produces |
|---|---|
| *fix it now* | the fix **and** the task — the task recording what was wrong, what changed, and how the fix was verified |
| *not now* / *never* | the task, and that is the whole outcome; a defect nobody plans to fix still costs the next reader a rediscovery |

There is no third outcome. **"Fixed, mentioned in the report, untracked" is the failure this section
exists to stop** — measured: an adoption run found two real defects in a consumer repo, fixed both,
verified them against a passing suite, said out loud that it would rather file them than fix them
silently, and filed nothing. What it handed back was a repo that now had a rulebook and a lifecycle,
so the next agent to read it will take anything untracked as something that was never wrong.

**Two orderings apply, and they are not the same ordering.**

1. **Fixing** — the layer fill is what adoption is *for*, so a found defect never displaces it:
   finish step 3, then deal with defects. **Unless the defect blocks the fill** — a repo whose build
   is broken cannot have [[populate-tests]] `adopt` wire a runner — in which case handle it at the
   delegation it blocks, and say in the report why it jumped the queue.
2. **Filing** — a task needs a `tasks/` tree to land in, and `/tasks init` runs *inside* step 3 (see
   [LAYER.md](../new-project/LAYER.md) § *Ordering*). So filing always follows that delegation,
   whatever the fixing order did. A defect found while surveying a repo with no `tasks/` yet is
   **reported at step 1 and filed later in the same run** — never dropped for want of somewhere to
   put it.
   - **A found defect suspends step 1's complete-table exit.** That exit assumes the only thing left
     undone was the fill; a defect is not layer work, so it outlives a complete layer. On an
     already-adopted repo `tasks/` is already there, so the task is filed straight away — and the run
     still owes step 4's *Defects found* section. Ending at the survey table with a defect listed
     under it and no id is the untracked outcome arriving by a second route.

**File through the owning verb, never by hand — and into the adopted repo's tracker.** The defect
belongs to that repo, so the task lands in *its* `tasks/`, never the caller's: use `/tasks new` there.
[[tasks]] `spawn` is right **only** when the origin task already lives in the repo being adopted —
spawn resolves the origin from the in-flight task and inherits *its* parent and `feature:`, so run
from a different repo it files the defect into the wrong tree entirely. Hand-writing the file skips
the id allocation and the plan both.

**A fix to shipped behaviour carries a regression check**, per [[tasks]]'s standing rule — or the task
records why one is impossible, naming the reason. Expect the obvious check to be unavailable in
exactly these repos: a consumer that cannot build in isolation gets no CI gate at all (see
[LAYER.md](../new-project/LAYER.md) § *CI a repo cannot pass*), so *"cannot be verified apart from its
framework tree"* is a legitimate recorded answer. Silence is not.

**Repairing a file the repo owns does not breach step 3's never-overwrite rule.** That rule stops the
layer's version of a file from displacing the repo's own; a defect fix brings no layer version
with it. It still needs the user's go-ahead on the specific change, exactly like an amendment — show
what is wrong, offer the repair, and never fix a file unasked.

### 3c. Regenerate what this run invalidated

Adoption is the one pass that reshapes several trees at once, which makes it the likeliest thing in the
set to leave a **stale generated file** behind it. The repo's rule is that generated files are owned by
their verbs and *"keep it current"* means run the owning verb — so:

**An adoption that creates an input to a generated file owes a re-run of that file's owning verb.**

Derive the set from what this run **actually created**, not from a list here: walk
[LAYER.md](../new-project/LAYER.md)'s rows, whose **Owner** column already names the verb for each shape,
and ask of each artifact you wrote *"is anything's output computed from this?"*. A list in this file would
go silently wrong the day the layer gains a row. Today's real edges: creating `docs/features/` makes
`tasks/README.md`'s feature slice and drift callout renderable, so [[tasks]] `triage` is re-run;
`CHANGELOG.md` feeds nothing; and `docs/specs/.map.yml` feeds the spec **bodies**, which stay an offer
rather than a tail step — `/specs regen` is real token spend.

**Render, compare, and only then write.** The obvious implementation regenerates and diffs afterwards,
by which point anything lost is already gone. Produce the new content first, compare it with what is on
disk, and branch:

| The comparison shows | Do this |
|---|---|
| a pure no-op | **write nothing, and say nothing.** A re-run that finds nothing to do still writes nothing at all — that invariant outranks the tidiness of mentioning it |
| only added or updated **derivable** rows | regenerate, and report it under `regenerated` |
| content the verb **cannot reproduce** would be removed | **stop.** Report what would be lost and where it belongs; offer, never assume |

That last row is not a new rule — it is step 3's *"never overwrite a file the repo already owns"* applied
to a file whose shape a verb happens to own. **The repo still owns the content**, and a consumer's
dashboard may legitimately carry provenance no verb can recompute (a tree imported from a spec document
is the standing case). Where such content should live instead is the agent guide's rule — nothing in a
generated file that its verb cannot derive — so the report has somewhere concrete to point.

This also covers a generated file written by an **older template**, with nothing else needed: re-running
the owner brings it to the current shape, and the gate above is what stops that from eating content on
the way. A *current-looking* generated file is not evidence it is current, exactly as a present config is
not evidence it carries today's fields.

**Never hand-shape a generated file to satisfy this step.** It is a verb re-run or it does not happen; a
row whose verb cannot be invoked is reported unregenerated. Hand-writing the shape is the same violation
one layer along, and it is the tempting shortcut when a verb is awkward to call.

**The regenerated files ride in the adoption commit.** A dashboard landing one commit later is a diff
nobody reviews and one the user did not ask for.

### 4. Report what changed

Report by outcome. Three buckets for what this run **did**:

| Bucket | Carries |
|---|---|
| **created** | what was written |
| **amended** | a file the repo already owned, changed with the user's consent — and *what* changed inside it: a section appended, a section replaced, lines added. **Never report an amendment as a creation**; on the upgrade path amendment is the normal outcome, so this is the busiest bucket, not an exotic one |
| **left alone** | why — "present already", "you declined" |
| **regenerated** | a generated file this run re-derived because it created one of its inputs (step 3c) — name the file *and* the verb that produced it. It needs its own name because the user did not write these files and should not have to work out why they moved; folding them into `amended` says they changed someone's own work, which is the opposite of true. **Report a declined or blocked regeneration here too** — silence reads as "nothing needed" |

Then **one bucket per surveyed state the three above do not already absorb** — `present` is
*left alone*, and a `missing` row you filled is *created*. [LAYER.md](../new-project/LAYER.md) owns
the state list, so a state added there that no outcome bucket absorbs gets a bucket here named after
it, whether or not this page mentions it. What follows is **what the report owes for the states that
exist today**, not a copy of the list — when that file gains a row, the rule above covers it and this
page does not need editing:

- `present, elsewhere` — **where**: the paths or form actually found. Never offer to create a second one.
- `present, outdated` — **what the owner's init reported as the delta, and whether it was reconciled.** "Brought up to date" and "nothing to do" are different outcomes; blurring them is how an old shape survives a pass that claims to reconcile it.
- `present, uncommitted` — whether the offer to land it was taken. Silence loses the artifact at the next clone.
- `unknown` vs `missing` — **which of the two, and why**: "could not determine X", "needs a decision", "blocked on a remote". *"I could not tell"* and *"you don't have it"* are different claims, and collapsing them here re-introduces one layer later the defect the survey just avoided.
- `missing, not offered` — **the reason**, re-derived this run rather than recalled from the last one (the survey and this report are stdout; nothing persists a verdict, and [LAYER.md](../new-project/LAYER.md) § *Detect what the repo has* explains why nothing needs to). Print it every run: the line is status, not a question, and the offer stays suppressed only while the evidence still holds. Where a task owns the blocker, name it here as information — a re-run re-reads the evidence, never that task's state.

**Defects found** get their own section, never a bucket. The buckets describe what this run did to
the **layer**; a defect is the repo's own code, so `created` and `amended` would each state something
false about it. One line per defect: what was wrong, whether it was fixed and verified or left as
found, its task id, and — if it jumped the fill queue — why. A defect listed here with no task id
means step 3b was skipped.

**Content** staleness inside a present artifact — prose that no longer describes the repo — is an
**aside**, never a bucket. A stale *shape* is the opposite: it gets its bucket, because an owner
reported it. See [LAYER.md](../new-project/LAYER.md) § *Presence and shape, not content currency*
for the line between them.

Then the next step: `/feature new` for stakeholder-facing work, `/tasks new` for a defined unit.

The report is the deliverable as much as the files are. An adoption whose output is "done!" leaves
the user unable to tell what was touched in their own repo.

## Conventions

- **No `Co-Authored-By:` trailers** in any commit it might create.
- PowerShell-compatible commands.
- Offer the adoption commit; never commit unasked.
- **Git policy is read, not inferred.** Whether to cut a branch, and whether to merge, comes from
  `tasks/.config.yml`'s `integration:` field. Absent → **ask, and backfill it** as part of the
  adoption; an absent declaration is the thing this skill reconciles. Never infer the policy from
  `git log` — a squash-merge repo and a commit-straight-to-main repo produce the same history, which
  is why [[tasks]] forbids the inference outright. And **never delete a branch on inference**:
  cleanup is its own ask, however tidy the log looks. (Adoption-side only — `new-project` has no
  history to misread.)
- Ask before `git init` on an untracked repo, and surface the resolved root when an **ancestor**
  repo already tracks the directory — only the user knows whether that ancestor is intended.

## Related skills

- [[new-project]] — the greenfield front door. Same layer, opposite starting point; both work from [LAYER.md](../new-project/LAYER.md), and **the layer-parity rule means a change to one is a change to both**.
- [[tasks]] — `init` creates `tasks/`; adopts a pre-skill tree without disturbing it.
- [[specs]] — `init` re-discovers the area map and proposes a delta.
- [[populate-tests]] — `adopt` mode wires a runnable test harness.
- [[verify-conventions]] — the payoff of adoption: it reads the `## Conventions` block this skill makes sure exists.
- [[roll-changelog]] — offered for the changelog backfill.
