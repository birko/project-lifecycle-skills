---
id: TASK-106
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: tasks-pick
created: 2026-09-08
depends-on: []
blocks: [TASK-079, TASK-105, TASK-107]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-079-3]
pr: null
github-issue: null
jira-key: null
---

# A subagent spawned in this repo is never a cold reader, so the drill method cannot be run as written

## Context

`skills/populate-tests/SKILL.md` § *The cold drill* closes its list of load-bearing prompts with:

> **A fresh agent with no prior context is runner enough.** Tell it that it is running a drill;
> withhold only the change.

**That sentence is false in this repo, mechanically.** A subagent spawned here loads the project
guide (`CLAUDE.md` → `AGENTS.md`), and § *Naming* lists the skill set verbatim —
`verify-conventions`, `verify-intent`, `populate-tests`, `roll-changelog`, `fix-next`,
`new-project`, `adopt-project`, `improve-architecture`, `tasks`, `feature`, `specs`, `roadmap`,
`tdd`, `domain`. A runner therefore starts holding the answer key to any drill about this repo's own
prose. TASK-068 wrote § *The cold drill*; this is a defect in what it produced.

### How it was measured, 2026-09-08

Running TASK-079's outstanding item, a runner was handed a table of 14 capability-area names and
titles and nothing else — no repo, no files, an explicit no-tools constraint, and it used none.

Its report named `grill-me`, `handoff`, `populate-tests`, `fix-next`, `new-project`,
`adopt-project`, `roll-changelog`, `domain`, `tdd` and `write-a-skill`. **None of those strings
appear anywhere in the brief it was given.** It could not have produced them from its input. It
disclosed the contamination itself and flagged its individually affected answers, which is the only
reason that drill yielded anything usable.

### There are TWO channels, and cwd only closes the weaker one — measured 2026-09-08

The first diagnosis blamed `AGENTS.md`. That is real but secondary, and the obvious remedy — run the
drill from another repo — **does not work**. Measured directly:

| Runner | Sees the 18 skill names? |
|---|---|
| subagent here | yes |
| `claude -p` in `C:/Source/WebChecker` (no guide, no `tasks/`, no `docs/specs/`) | **yes** — full roster, with descriptions |
| `claude -p --disable-slash-commands` in the same repo | **no** — *"No skills or custom slash-commands are loaded in my context right now."* |

**The second channel is the product's own installer.** `install.sh` links `skills/` into
`~/.claude/skills`, which is **user-level**, so every Claude Code session on this machine — any
directory, any repo, no repo — receives the full roster in its system prompt. Changing the working
directory closes the `AGENTS.md` channel and leaves this one wide open.

The first drill proves the split rather than merely suggesting it: its runner named `grill-me`,
`handoff` and `write-a-skill`, and **none of those three appears in `AGENTS.md` § *Naming*.** They
could only have come from the roster.

**So the sharp version of this defect: installing the product is what makes every agent on the
machine a contaminated reader of it.** A consumer repo is the right fixture for drilling *behaviour*
and is no help at all for drilling *prose about the skill set*.

### A remedy exists, and it is one flag

`claude -p --disable-slash-commands`, run with cwd in a repo whose guide names none of these skills
(`WebChecker`, `EventSourcing`, `ClientApi.CSharp`, `WhMan`, `DataSetExtractor`, `gameshow-app`, the
`FisData.Stock*` set — all verified guide-free 2026-09-08). In `-p` mode the runner's attempt to read
`~/.claude/skills` was refused by the permission prompt, so the roster cannot be recovered through
tools either. Note the consumer repos that **have** adopted the layer (Symbio, WorkoutTracker, Latent,
Presenter, BardStudio, DraCode) each name at least one skill in their guide and are therefore *not*
clean rooms for this particular drill.

### Consequences, in order of reach

1. **The claim is wrong exactly where it is load-bearing.** A repo whose product *is* prose is the
   case § *The cold drill* was written for, and it is the case where the method does not work.
2. **Every subagent-run drill in this repo is weaker than its record says.** TASK-079's progress log
   describes two prior readers as *"given only the names and titles — no repo, no files"* and never
   records **how** they were obtained. If they were subagents, they were contaminated identically
   and the record overstates them. Nothing written down can settle that now, which is the second
   half of this defect.
3. **The method's existing contamination guidance does not cover this channel.** *"A rule that cites
   a named file in a named repo cannot be drilled on that repo"* addresses contamination arriving
   through **the instructions**. This arrives through **the runner's ambient context**, is
   independent of how carefully the brief is written, and is always open.

## Acceptance criteria

- [x] § *The cold drill* states that a runner inheriting the project guide is not cold — as a
      property of the **runner's context**, not of the brief
- [x] Contamination-by-instructions (already covered) and contamination-by-ambient-context (new) are
      drawn as two distinct channels, each with its own check
- [x] The section documents the verified runner-acquisition recipe above — the flag **and** the
      guide-free cwd, since either alone is insufficient — and says how to confirm a runner is cold
      before trusting its report
- [x] It states that a consumer repo fixes the guide channel only, so "drill it on another project"
      is recorded as the wrong answer rather than left as an obvious-looking one
- [x] A drill record must name **how the runner was obtained**, so "was this reader cold" is
      answerable afterwards instead of assumed — the same reconcile-don't-assume principle
      AGENTS.md § *An owner verb reconciles* applies elsewhere
- [x] TASK-079's progress log is **appended** with what is and is not known about its two prior
      readers — not rewritten, and not tidied into a claim the evidence does not support
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Re-running TASK-079's cold read.** That is TASK-079's own outstanding item; it stays unticked
  until a cold reader exists, which is why this task `blocks` it.
- **The findings the contaminated drill produced anyway — TASK-105.** They stand as conclusive
  negatives independently of this fix.
- **Changing how subagents inherit the project guide, or how the installer places skills.** Both are
  correct behaviour serving other purposes; this task documents the consequence, it does not
  re-litigate user-level installation ([ADR 0009](../../docs/adr/0009-installers-link-rather-than-copy.md)).
- **Giving the rule an enforcement point** — **TASK-107**. This task states the rule; nothing here makes
  a gate refuse a drill record that omits the acquisition line.
- **Auditing every past drill record in the tree.** If the method change makes that worth doing, it
  is its own task — this one fixes the method and annotates the one record it measured.

## Human test plan

- [x] Acquire a runner by whatever method the fixed section documents, and give it the same 14-name
      table from the TASK-079 brief. Expected: its report contains **no skill name that does not
      appear in the brief**. That single mechanical check is what "cold" reduces to here, and unlike
      a judgement about the reader's answers it cannot be argued with. — **PASSED 2026-09-08**, see
      the progress log for the run and the one judgement call it required.

## Implementation plan

> **Acceptance criteria question — SETTLED 2026-09-08.** Criterion 4 states the rule but not where it
> must *land*. Decision: state it **once**, in the method owner, and add no second copy here; the
> enforcement half — whether `close` step 5 and `templates/TASK.md` gain a check or a slot — is
> **TASK-107**, spawned rather than folded in. The criteria below are unchanged.

### What is actually wrong, in one line

`skills/populate-tests/SKILL.md` defines coldness as a property of the **brief** (*"withhold only the
change"*), and the whole section is built on that. Coldness is a **conjunction**: the brief withholds the
change **and** the runner's ambient context does not already hold the subject. The second conjunct is
missing everywhere, including from the section's own definition.

### Step 1 — fix the definition sentence

*"hand the changed instructions to a reader who has not seen the change"* becomes two-part: a reader who
has not seen the change **and whose context does not already carry the subject**, with a forward pointer
to the new subsection. One clause. It is the sentence every downstream pointer glosses — `AGENTS.md`
§ Testing, `close.md` step 5, `templates/TASK.md`, `intake.md` — so fixing it here fixes all four
glosses without touching them.

### Step 2 — replace load-bearing item 5

Keep the numbering (the heading promises *"five things they do not cover"*).

- **The false half:** *"A fresh agent with no prior context is runner enough."* A spawned subagent has no
  prior *conversation*; it does not have no *context*. It loads the project guide before it reads a word
  of the brief.
- **The surviving half:** *"concealing the exercise buys nothing, concealing the change is the entire
  mechanism"* — still true, and it is why the rewrite must not swing to "conceal everything".
- **New content, phrased as a property of the runner:** the brief cannot make a contaminated runner cold,
  so acquiring the runner is a separate step with its own rules → § *Acquiring a cold runner*.

### Step 3 — new subsection: two channels, the recipe, the confirmation

Insert between the brief-shape list and § *Choosing a target*. **Placement rationale, for the commit
message:** § *Choosing a target* is about the **target**; this is about the **runner**, and putting
runner-acquisition inside target-selection is what let the second channel hide for as long as it did.

1. **The two-channel table** — a branch, so a table:

   | Channel | Arrives through | Closed by | Confirmed by |
   |---|---|---|---|
   | the **instructions** | the brief, and a target the rule has already adjudicated | § *Choosing a target* | naming which question is contaminated, and discounting that part |
   | the runner's **ambient context** | whatever the runtime loads into every session — project guide, user-level installed instructions | acquiring the runner outside both | the pre-flight probe and the report scan |

   Rationale inline: channel two is **independent of how carefully the brief is written and is always
   open**, which is exactly why the existing per-question rule does not reach it.
2. **The recipe**, as *rule* + *measured instance*, never as a machine-specific command list:
   - **Rule:** the runner must be acquired outside **both** loaders. Either half alone is insufficient,
     and that is measured, not reasoned.
   - **Measured instance, 2026-09-08:** reproduce the three-row table from § Context. **The middle row is
     the whole point and must survive into the prose** — it is what kills the obvious remedy.
   - **Why cwd alone fails**, mechanism named: the installer links `skills/` into `~/.claude/skills`,
     which is user-level, so every session on the machine gets the roster in its system prompt. Say
     plainly this is correct behaviour serving another purpose, then state the consequence: **installing
     a prose product is what makes every agent on the machine a contaminated reader of it.**
   - **The closed tool path:** in print mode the runner's attempt to read `~/.claude/skills` was refused
     by the permission prompt, so the roster is not recoverable through tools either. Without that line a
     reader assumes the flag is cosmetic.
3. **Confirming coldness** — two signals, both arriving **in-band at no extra cost** (grilled 2026-09-08):
   - **The self-report.** Every brief opens by asking the runner to list what instruction files and skills
     it currently has loaded. It leaks nothing about the change, so it is free, and the answer arrives with
     the report. **This is specified here, not as a sixth ask** — the five asks are about the drill's
     *subject*; this is about the *runner*, and § *The brief's shape* keeps its count.
   - **The post-hoc scan.** The report must name **no term from the subject's own vocabulary that the
     brief did not supply**. One is enough.
     **Scoped deliberately, and the scope is the whole point:** "no proper noun absent from the brief"
     over-triggers — a genuinely cold reader writes `README`, `YAML`, `CI` unprompted, and the flagged run
     said *"this is a README section"* while being contaminated for entirely different reasons. A check
     that fires on clean reports gets muted, which is the argument that already rejected widening the
     wikilink check at 24:0. Scoping it to the drilled vocabulary catches the measured case exactly (ten
     skill names) and stays quiet otherwise. The price is one judgement call — what counts as the
     subject's vocabulary — and the prose states that price rather than hiding it.
   - **A separate pre-flight probe is required only** when acquiring a runner by a route not yet verified
     on this machine, or when the runtime or its flags have changed. Not per drill: a contaminated drill
     still yields conclusive negatives, so spending one is a partial loss, not a total one, and a required
     step that feels redundant is the kind that gets skipped.
   - Tie back to the asymmetry already in the section: a runner failing either signal still yields a
     conclusive **negative**; only the pass direction is lost.
4. **"Drill it on another project" is the wrong answer** — its own bolded line, because it is the remedy a
   reader reaches for and it closes one channel of two. Add the discrimination: a consumer repo is the
   right fixture for drilling **behaviour**, and no help at all for drilling **prose about the skill
   set**. State the fleet fact as a property (*every repo that adopted the layer names at least one skill
   in its guide; the clean rooms are the repos that never adopted it*) plus **a test the reader can
   run** — grep the candidate repo's agent guide for the terms the drill is about.
   **Do not paste the enumerated repo lists into the skill:** they are lists that grow, and § Conventions'
   *defer to a shared inventory — never restate its lists* applies. They stay in this task's record.
   *Settled by the codebase, not by taste (checked 2026-09-08):* all **13** repo mentions across
   `skills/` are **measured instances** — *"Measured on `WorkoutTracker`, 2026-09-01"*, *"Observed in
   `Presenter`"*, *"measured on `Symbio`"* — and **not one** is an enumerated list of repos-in-a-category.
   So name `WebChecker` as the dated instance and keep the seven-repo list in this task's record; that is
   the house pattern, not a compromise.
5. **A drill record names how the runner was obtained** — the command, the cwd, and the result of the
   coldness check, recorded wherever the drill is recorded. Cite `AGENTS.md` § *An owner verb reconciles;
   it does not assume* by name rather than restating it, and cite the measured failure: a record saying
   *"given only the names and titles — no repo, no files"* describes the **brief** and is silent about the
   channel that decides, which is why TASK-079's first two readers can no longer be classified.

### Step 4 — one-line channel label at the top of § *Choosing a target*

So the two subsections read as a pair rather than one general section plus a special case: *this section
closes channel one; the runner's context is channel two, above.* No content moves.

### Step 5 — register the rule in `AGENTS.md` (register-on-introduce)

Extend § Testing's *"Every new skill gets at least one lint-visible invariant … and a drill recorded on
its task"* with the acquisition clause **and a pointer, not a copy**. The drill-record requirement is
cross-cutting over `tasks/`, not local to `populate-tests`, so § Conventions is where it must land in the
same change. Keep it to a clause — the neighbouring bullet already points at the method and must not grow
a second summary of it.
### Step 6 — append to TASK-079's `## Progress log`

Do **not** touch the two earlier readers' entries, and do **not** touch human-test-plan item 1. The log
already records *what is not known*; this supplies **what is now known** and closes the loop:

- **Known:** the two channels and their measurement; that the user-level roster loaded in every session
  on this machine regardless of cwd; therefore **no acquisition method in use before 2026-09-08 excludes
  contamination** — subagent or print-mode session, the roster was loaded unless a flag nobody knew
  mattered was passed.
- **Not known, and now permanently:** whether readers one and two were subagents. Nothing recorded it and
  nothing can reconstruct it.
- **What follows, stated conservatively:** their pass-direction verdicts are weak evidence; their
  *objections* survive by the asymmetry the method names; the renames applied on their strength are **not**
  being unwound, because the map was verified mechanically and the names now stand on their own review —
  say that, rather than implying the renames were cold-read-backed.
- **What is now possible:** a cold runner is obtainable, so item 1 becomes runnable — under TASK-079, not
  here.

Explicitly not done: rewriting, tidying, or ticking anything. An append is the honest shape, which that
log already argues for itself.

### Grill outcome, 2026-09-08

Five branches taken; two settled by reading the codebase rather than by opinion. The changes above are
already folded in — this block records what moved so a later reader does not re-open them.

| Branch | Resolved | On what |
|---|---|---|
| where the section lives | inline, unchanged | peer file sizes — the size objection does not hold |
| naming repos in skill prose | dated instance, not a list | 13 of 13 existing mentions use the instance form |
| the post-hoc scan's wording | scoped to the drilled vocabulary | *"no proper noun"* fires on clean reports; muted checks are worthless |
| the pre-flight probe | folded into the brief; separate probe only for unverified routes | a contaminated drill still yields negatives, so the insurance is worth less than the friction |
| where the self-report goes | outside the five asks, owned by the new subsection | it is a question about the runner, not the subject |

### Step 7 — gate

- `bash .github/workflows/skills-lint.sh`.
- `bash .github/workflows/skills-lint-test.sh` as a **contract pin, not evidence** (§ *Prove the guard can
  fail*).
- Run this task's own `## Human test plan`. **Contamination check on the drill itself:** the runner runs
  *under* the recipe and is never asked *about* the method, so the change does not adjudicate its own
  question.

### Is anything here lint-checkable? No — and the task says so rather than leaving it unasked

- The lint's five checks are structural and scan `skills/` and `skills-pi/` only. Drill records live in
  `tasks/`, which the lint never reads.
- A check like *"a task with `findings: [DRILL-*]` must contain an acquisition line"* fails on both sides:
  drill results are also recorded in human-test-plan lines and progress logs with no frontmatter marker
  (false negatives), and *"names how the runner was obtained"* is prose any keyword satisfies trivially
  (false positives). A check at that ratio gets muted — the same argument that rejected widening the
  wikilink check at 24:0.
- **Therefore no change to `skills-lint.sh`, and the *"not done until a case fails without it"* rule is
  not triggered.** Record this in the close notes so the next reader does not re-derive it.
- **One lint interaction to watch while editing:** check 4 greps raw text for `/word word --flag`. Do not
  write the recipe in a form beginning with a path, or it parses as a cross-skill invocation.

### Trade-offs

| Decision | Chosen | Rejected, and why |
|---|---|---|
| Where the content lives | inline in § *The cold drill* | Moving it to a reference or verb file. Four external pointers name that section by path and `populate-tests` has no `verbs/`. **The size objection was measured and does not hold:** at ~277 lines the file stays smaller than `adopt-project` (402), `fix-next` (346) and `tasks` (311), so *router stays small* is not breached relative to its peers. Name the growth in the commit anyway. |
| Generality | rule stated harness-agnostically; the flag as a **dated measured instance** | Writing the command as *the* rule. This skill ships into consumer repos on other stacks and into pi; a flag-shaped rule dates the moment a harness changes. |
| Repo names | property + a grep the reader can run, plus `WebChecker` as the dated instance | Pasting the verified lists in. They grow — a repo adopts the layer and silently changes sides. **No longer a judgement call:** 13 of 13 existing repo mentions in `skills/` use the instance form. |
| Criterion 4's landing | stated once in the owner | Adding it to `close` and the template too — a third copy of a rule the owner just gained. **Settled: the enforcement half is TASK-107.** |

### Split signals — handled, not deferred silently

- **Step 6 is independently completable** (different tree, needs none of steps 1–5) but is **inside** the
  criteria — do not split; just know it does not block the prose work.
- **Step 5 (`AGENTS.md`) is not in the acceptance criteria** — required by register-on-introduce, which
  the criteria do not mention. In scope by convention, one clause. Dropping it means `/verify-conventions`
  flags the diff at close.
- **The close-gate enforcement half is outside the criteria** — spawned as **TASK-107** (`depends-on: TASK-106`). Do not implement it here.
- **Harvesting the verification run for TASK-079's item 1** is out of scope here; use the run only for the
  mechanical scan. If it does yield a usable cold read, that unblocks TASK-079 and is closed *there*.
- **Real risk:** if the recipe does not reproduce on the day, or the pre-flight probe shows contamination
  anyway, the human test plan stays unticked and this closes to `review`, not `done` — the section's own
  *a caveat disappears, an unticked box does not* rule, applied to the task that wrote it.
- **Second-order risk, worth one line in the section:** the flag is harness behaviour, not a guarantee.
  That is why the probe is the confirmation and the flag merely the current means — if a future runtime
  loads the roster despite it, the probe still catches it and the recipe degrades gracefully.

## Progress log

- picked 2026-09-08 via `/tasks pick`; no branch cut — `.config.yml` declares `integration: single-branch`.
- planned via the `Plan` subagent, then **grilled**: five branches, two of which were settled by reading
  the repo rather than by opinion (peer file sizes; 13 of 13 existing repo mentions using the instance
  form). The grill outcome table is in the plan section. One grill answer — folding the coldness probe
  into the brief — exposed a consequence the plan had missed: it would have quietly added a sixth item to
  a list whose count is in its own heading.
- steps 1–6 implemented. **The section grew 76 lines, not the ~30 the plan estimated** — 247 → 323, which
  puts this file above `tasks` (311) where the estimate had put it below. Still under `fix-next` (346) and
  `adopt-project` (402), so the inline decision holds on its own reasoning; recorded because the number
  the decision was taken against is not the number delivered.
- **human test plan run 2026-09-08 by the newly documented recipe, and it passed.** Runner acquired with
  installed skills disabled, cwd in `WebChecker`; brief was the 14-name table with the self-report as its
  opening ask. Task 0 came back **`NONE` — no guide, no skills, no slash-commands** — and the report
  contains **zero** of `grill-me`, `fix-next`, `new-project`, `adopt-project`, `populate-tests`,
  `roll-changelog`, `tdd`, `write-a-skill`, `verify-conventions`, `verify-intent`,
  `improve-architecture`. The first drill, 2026-09-08 earlier, named **ten** of them.
- **the scoped scan earned its keep on first use.** It produced exactly one judgement call — the word
  *domain*, absent from the brief — and the context settled it as ordinary English (*"a controlled
  vocabulary pinning each **domain** term to one definition"*), not the skill name. The rejected wording,
  *"no proper noun absent from the brief"*, would additionally have fired on `README`, `YAML` and several
  others in the same report. One paid judgement call versus a muted check: the grill picked correctly.
- run preserved at `scratchpad/DRILL-106-cold-read-2026-09-08.txt`. **It is also a usable cold read of the
  14 area names** — the first one this repo has ever obtained. That belongs to TASK-079's item 1 and is
  deliberately not harvested here.
- closed 2026-09-08 via `/tasks close`. Gate: standards ⚠1 (fixed — and it caught a real dashboard drift, `39/62` against a derived `39/63`), fidelity ⚠1 (fixed — a paraphrase where the plan required a named citation), correctness ✅ clean on this diff, security not applicable (prose only). The correctness pass scoped itself to `origin/main...HEAD` and surfaced 8 adjacent findings in committed code; filed as CR-1…CR-8 via `/tasks intake --epic EPIC-002` (TASK-108…112, two linked into TASK-081/083) rather than folded in. `integration: single-branch`, so no branch and no merge step — `done` means on the default branch.
