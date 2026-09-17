---
id: TASK-127
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-16
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-109-1, DRILL-109-2]
pr: null
github-issue: null
jira-key: null
---

# Four steps say "ask the user" and none of them says what to ask, or what happens when nobody answers

## Context

**From the cold drill run for TASK-109 on 2026-09-16** — two runners, `--disable-slash-commands` in a
guide-free scratch root, both confirmed cold. Each was told: *"if the instructions have you ask the user
something, write that question out VERBATIM and continue as if it went unanswered."* Neither could, and
both said so unprompted. Filed at epic level because the fix spans two skills and neither owns it alone.

### DRILL-109-1 — three ask-steps in `tasks`, no question text

The B1 runner, on `/tasks init` against a folder with no git and no user:

> *"No question text is supplied, so there is nothing to quote to you verbatim as **my** question — the
> instruction **is** the prompt."*

| Where | What it says |
|---|---|
| `skills/tasks/verbs/new.md` § Mode detection flow, step 2 | *"**Ask user** via AskUserQuestion with three options: local / hybrid (github) / hybrid (jira). Pre-select the suggested one."* |
| `skills/tasks/verbs/init.md` step 3 | *"A field whose value is a **real choice** (`integration:`) is **asked**, never defaulted"* |
| `skills/tasks/SKILL.md` § Shape detection, step 4 | *"Ambiguous → ask the user once and write `.config.yml` so the choice sticks."* |

The third fired in the drill and nothing records it: `project/` had no `*.sln`, no `.git` and no existing
config, so steps 1-3 all fell through — the ambiguous case exactly — and the runner picked a location by
inference from the brief rather than from the skill.

### DRILL-109-2 — `/specs init`'s blessing has no wording *and* no mechanism

The B2 runner:

> *"The init header says the run is to 'scan the codebase, propose a capability map, **let the user bless
> it**, write `.map.yml`.' Step 4 says present the table; step 6 says write 'the blessed areas'. **Nothing
> between them says how blessing is obtained or what to do when it is not forthcoming.**"*

It proceeded as if blessed, and wrote the question itself because the skill supplies none.

### Why one task, and why this is not cosmetic

Both are the same defect: **a step names an interaction without specifying either half of it** — the
question to put, or the path when no answer comes. The two halves fail differently and both matter. No
wording means every run invents its own, so two runs of the same verb ask materially different questions
and neither is reproducible. No unattended path means the run either stalls or, as happened twice here,
silently promotes a *suggestion* into a *decision* — which is the exact defect class TASK-109 just fixed
one layer down, arriving through the interaction instead of through a template.

### Re-verified by hand, 2026-09-17 — one rescope, and the pack is wider than four

Each cited site was read in the source rather than trusted from this file.

| Site | Verdict |
|---|---|
| `tasks/verbs/new.md` § Mode detection flow, step 2 | **Holds.** No question text, no no-answer path. |
| `tasks/verbs/init.md` step 3 | **Rescoped — the no-answer half is already built.** TASK-035 landed *"Unattended, with no user to ask and no arg, leave the field absent and report it unresolved"*, and the Absent branch says the same at length. What is missing here is **only the question text**. This file's claim that both halves are absent at all four sites is false for this one. |
| `tasks/SKILL.md` § Shape detection, step 4 | **Holds, fully.** No question text, no unattended path, and *"ambiguous"* itself names no condition. This is the one that fired in the drill. |
| `specs/verbs/init.md` blessing | **Holds.** The header names it, step 4 presents, step 6 writes *"the blessed areas"*, and nothing in between says what blessing is or what an unblessed run does. |

**Pulled in as sharing the root cause** (same flow, same interaction — [[fix-next]] step 3, *findings
travel in packs*):

- `new.md` mode-detection steps **3 and 4** (*"ask for the repo"*, *"ask for the project key"*). Stating
  step 2's question while steps 3-4 of the same flow stay undefined fixes one third of one flow.
- `init.md` step 3's **mode-conflict** ask (*"surface it and let the user decide"*) — inside the cited step.
- `specs/init.md` step **2** (*"never drop an existing area without asking"*) and step **4** (*"unmapped
  files the user declined to map"*). These are not separate interactions from the blessing; they are the
  blessing at two other moments, and the mechanism AC3 asks for has to cover them or it is not a mechanism.

**Not pulled in — spawned instead:** `specs/init.md` step 1's meta-root ask (*"ask whether the user wants
meta-level specs or a specific subproject"*). Same defect shape, but it resolves project scope rather than
blessing a map, so folding it in would widen this task rather than complete it.

**Relationship to [[TASK-092]], stated rather than discovered later.** That task holds the *reachability*
half for `init.md` — the unattended branch describes a state no arg can put the verb in — and explicitly
leaves open whether the answer is a flag, inheritance from the caller, or a rewrite that needs neither.
This task states each ask's outcome in **attendance-independent** terms (*if the question cannot be put or
goes unanswered, do X and report Y*), which satisfies AC2 without choosing among those three. It does
narrow TASK-092 toward its own third option; it does not close it, and CR-035-2 (*declined* and *never
asked* are the same absence) is untouched here.

**This repo already has the shape of the answer**, which is why this is a gap and not an open design
question: `/tasks close` has `--unattended`, and `AGENTS.md` § Conventions requires that such a flag
*"define behaviour at every point that needs it"*. These four points have no such definition.

## Acceptance criteria

- [x] **Every ask-step named in Context** — the four originals plus the ones pulled in on re-verification
      — states **the question actually put**, not a description of the question, so two runs ask the same thing
- [x] Each states what happens **when no answer comes**, and the unattended outcome is a *reported
      unresolved state*, never a silently-promoted suggestion. **Already met on arrival at `init.md`
      step 3** (TASK-035 built it); that site owes only the question text, and its existing wording is
      the model the others are brought up to, not something to rewrite
- [x] The `/specs init` blessing has a stated mechanism, not just a named one — what constitutes blessing,
      and what an unblessed-but-proceeding run writes and reports
- [x] The rule is stated once and referenced, not restated per site — where it belongs is part of this
      task's judgement, and `AGENTS.md`'s existing `--unattended` convention is the obvious anchor
- [ ] `SKILL.md` § Shape detection's ambiguous branch is reachable in a drill and produces a recorded
      question rather than an inferred location
      **Half met.** The *recorded question* half is built and proven by step 6: the branch now defines
      what `ambiguous` means (three named signals), puts a verbatim question, and states the no-answer
      path. The *reachable in a drill* half is a claim only a drill can settle, and it is unrun — this
      box stays unticked until it is.
- [ ] A cold drill re-run of both verbs quotes the questions verbatim rather than reporting it cannot
      — ⚠ **NOT MET, and not deferred quietly**: it needs a runner that has not seen this change *and*
      whose context does not already hold these skills. This session is neither. It is the whole reason
      this task closes at `review`.
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Changing what any of the four questions decides.** `mode:`, `integration:`, task-root placement and
  the area map keep their current semantics; this is about the asking, not the answer.
- Adding an `--unattended` flag to `init` — decide whether that is the mechanism, but building it out
  across every verb is its own task if it turns out to be the answer.
- The other drill findings from the same run — TASK-128, TASK-129.

## Human test plan

- [x] Re-run the TASK-109 cold-drill recipe against both verbs with no user available, and confirm each
      report can quote the questions verbatim and names each unresolved field — **run 2026-09-17, both held**
- [x] Confirm an unattended run writes no value that a user did not supply, for every one of the four
      — **held**; see the table in `## Drill record`

## Implementation plan

**Not drafted — recorded as a gap, not backfilled.** This task was driven by `/fix-next`, whose flow goes
pick → verify → fix with no plan step, so the placeholder survived the run. `AGENTS.md` § Working rules
requires a plan *before* work starts; writing one now would be a transcript of what was already done, which
is the defect § Working rules' own "create the task before implementing" rule exists to prevent. The
`## Progress log` and `## Outcome` below carry what a plan would have carried. **The skill gap is filed as
[[TASK-135]]** — `/tasks pick` offers the plan and `/fix-next` does not, although it picks.

## Outcome

**What the fix was.** These skills kept telling the agent running them to "ask the user" without ever
saying *what to ask*. So every run made up its own wording, and two runs of the same command asked
different things. Worse, none of them said what to do when there is nobody to answer — so a run would
quietly turn its own *suggestion* into a written *decision* and move on. Both cold runners in the drill
did exactly that: one picked where to put `tasks/` by guessing from its instructions, the other decided
the user had approved a map nobody had seen. This writes out all nine questions word for word, and says
for each what happens when no answer comes — always *report it as unresolved*, never *pick and pretend*.

**The step-6 split.** A bidirectional assertion over 9 ask-sites × 2 halves, HEAD vs working tree:
**0/9 before, 9/9 after**, exit 1 → 0. Fix-dependent, by name: `new.md` mode / github repo / jira key;
`init.md` integration / mode conflict; `tasks/SKILL.md` shape detection; `specs/init.md` area removal /
unmapped / blessing. **Contract pins, not evidence**: all 47 `skills-lint-test.sh` cases and
`skills-lint.sh` itself — green before and after, and green with this change absent.

**Judgement calls, and why the stricter option was rejected.**

- **The shared rule lives in `AGENTS.md` § Conventions and nowhere else.** The stricter reading of AC4
  ("stated once and referenced") wants a file both skills can *link*. Rejected: a skill file pointing at
  this repo's `AGENTS.md` is a dangling reference the moment the skill is installed in a consumer repo,
  and a new neutral shared file contradicts § *A vocabulary shared by several skills … the owner is
  wherever it already lives*. The split that resolves it: the **rule** is an authoring rule, read by
  whoever edits these skills, and this repo is where that happens; the **question text** is per-site data,
  different at every site, so writing it locally is not a restatement.
- **Nine sites, not the four filed.** `new.md` steps 3-4 are the same flow as the cited step 2, and
  `specs/init.md` steps 2 and 4 are the blessing at two other moments — fixing one third of a flow, or
  defining blessing while two of its asks stay undefined, is not a fix. Held the line at
  `specs/init.md` step 1's meta-root ask, which resolves project *scope* rather than blessing:
  **spawned as [[TASK-134]]**.
- **The assertion is not installed as a CI check.** Tempting, and wrong: it hard-codes a list of 9 sites,
  so a tenth ask-step added tomorrow passes it silently — the restated-list defect this repo lints for
  elsewhere. A *general* detector for "this sentence is an ask-step" is prose-shaped and would carry the
  24:0 false-positive profile § Conventions already measured and rejected. Recorded as a reviewer rule
  instead, which is the disposition that section gives an unrendered token and a template stub.
- **An unblessed `/specs init` writes the map rather than refusing.** Refusing is stricter and worse:
  `init` is chained by both front doors, which need the anchor file, and a run that wrote nothing would
  leave no record the question was ever reached. The stamp `coverage: unverified` is what makes writing
  safe, and step 2 already turns an `unverified` map back into proposals on the next run — so the
  unanswered question returns instead of being settled by silence. Blessing is now a precondition of
  `verified`, so the table and § *Blessing* agree rather than contradicting.
- **`mode:` is written with a comment, not a new schema field.** Writing a bare `mode: local` violates the
  rule this task just wrote; inventing a `mode-source:` key decides [[TASK-092]]'s open CR-035-2 question
  from the wrong task. Took the comment, and **wrote the tension into TASK-092** where its owner will see it.
- **Outcomes are phrased attendance-independently** ("if the question cannot be put or goes unanswered"),
  which satisfies AC2 without choosing among TASK-092's three mechanisms for asserting attendance. It
  narrows that task toward its own third option; it does not close it.

**Flagged but not fixed.**

- **The `## Human test plan` cold drill is unrun**, and AC6 with it. It needs a runner that has not seen
  this change *and* whose context does not already hold these skills — every agent on this machine holds
  them, since they are installed at user level. That is why this closes at `review`, not `done`.
- **[[TASK-134]]** — `specs/init.md` step 1's meta-root ask, same defect shape, deliberately not folded in.
- **[[TASK-092]]** — `mode:`'s declined-vs-never-asked gap, noted on that task's file.
- **`docs/specs/` has no bodies**, so step 7 respecced nothing; owned by TASK-080, already filed.

## Progress log

- step 2 — picked; ranked above TASK-133 because key 2 (reachability): these four ask-steps sit on the front doors every adopting repo runs, where TASK-133's `_loose` rescue fires only when the spawn origin is itself loose. Key 1 agrees — an unanswered ask writes a declaration nobody made, which every other skill then reads as authoritative. Key 5 too: observed by two cold runners, not harvested. Key 6 inert — every declared theme in the pool is `correctness-invariants`, and this task is parented to the EPIC so has no theme by construction. Excluded: TASK-130 (AC1 is a user decision), TASK-132 + TASK-131's drill (need a cold runner), TASK-067 (unmet depends-on).
- step 3 — verified: **held at three of four sites, rescoped at one.** Read each cited line in source rather than trusting this file. `new.md` step 2, `tasks/SKILL.md` § Shape detection step 4 and `specs/init.md`'s blessing hold exactly as filed. `init.md` step 3 is **rescoped**: its no-answer half was already built by TASK-035 (*"leave the field absent and report it unresolved"*), so it owes only the question text — Context and AC2 corrected before any writing, and that site's existing wording becomes the model the others are raised to. Pack pulled in (same flow / same interaction): `new.md` steps 3-4, `init.md` step 3's mode-conflict ask, `specs/init.md` steps 2 and 4. Spawned rather than folded: `specs/init.md` step 1's meta-root ask. Relationship to TASK-092 stated in Context — outcomes are phrased attendance-independently, which narrows that task's option space toward its own third option without closing it, and leaves CR-035-2 untouched.
- step 4 — layer: local. Every affected file is a skill definition in this repo; there is no upstream.
- step 5 — fix in AGENTS.md § Conventions (the shared rule, stated once — an ask-step carries its verbatim question *and* its answer-less path, with the two shapes an unattended outcome may take), skills/tasks/verbs/new.md (mode-detection steps 2/3/4), skills/tasks/verbs/init.md (step 3's `integration:` ask and its mode-conflict ask), skills/tasks/SKILL.md (§ Shape detection step 4 — `ambiguous` given a definition, a question and a no-answer path), skills/specs/verbs/init.md (new § *Blessing* defining the state, its question, its per-presentation scope and its unblessed outcome; step 2's area-removal ask; step 4's unmapped-files ask; the `unverified` list gains the never-blessed case; the `verified` row gains blessing as a precondition so the table and § *Blessing* do not disagree). **The rule lives in AGENTS.md only, and that is a judgement worth stating**: each site's question text is per-site data rather than a restatement, and a skill file cannot point back at this repo's AGENTS.md without breaking in a consumer install. Tests: lint OK, 47/47 regression cases green.
- step 6 — bidirectional assertion (populate-tests § *Prove the guard can fail*, third form), run over 9 ask-sites × 2 halves in a detached worktree at HEAD vs the working tree: **0/9 before, 9/9 after; exit 1 → 0**. Fix-dependent = all 9 sites, by name: new.md mode / github repo / jira key; init.md integration / mode conflict; tasks SKILL.md shape detection; specs init area removal / unmapped / blessing. Contract pins, **not evidence**: all 47 `skills-lint-test.sh` cases and `skills-lint.sh` itself — green before and after, and they would stay green with this change absent; they pin frontmatter, links, file refs and flag contracts, none of which this change touches. The assertion **independently corroborated the step-3 rescope**: `init.md integration` was the only site scoring `no-answer=yes` pre-fix, which is exactly the half TASK-035 had already built. **The script is not installed as a CI check, deliberately** — it carries a hard-coded list of 9 sites, so a tenth ask-step added tomorrow passes it silently, which is the restated-list defect this repo lints for elsewhere. A general detector for *"this sentence is an ask-step"* is prose-shaped and would carry the false-positive profile AGENTS.md already measured and rejected at 24:0. So the durable guard is the reviewer plus the cold drill in `## Human test plan`, which is **unrun** — it needs a cold runner in a fresh session, and this one is not.
- step 7 — respecced: nothing to respec. The map is usable (14 areas; `work-tracking` → `skills/tasks/**` and `specs-from-code` → `skills/specs/**` both cover this change), but `docs/specs/` still holds only `.map.yml` — no spec body has ever been generated, because TASK-080 (the first full harvest) is `todo`. Generating these from scratch here would be TASK-080's job and its diff would be "everything new", carrying no evidence for this fix. Requirements changed: none. Flagged, not skipped silently.
- step 8 — 5b gate, three axes reported side by side, not merged. **standards** ([[verify-conventions]]): rulebook = AGENTS.md § Conventions via the CLAUDE.md @import bridge, ladder rung 1; project extension none found; 8 of 8 changed files linted, 0 excluded. One ⚠ — TASK-127's own `## Implementation plan` never populated, against § Working rules *"Plan before implementing"* — **not backfilled** (a plan written after the work is a transcript) and the skill gap behind it spawned as TASK-135. One 💡 — the router grew 19 lines vs *"Router SKILL.md files stay small"*; judged acceptable and recorded rather than passed silently (no verb owns shape detection; 331 lines is mid-range among siblings at 255–402). Register-on-introduce satisfied: the ask-step contract is recorded in § Conventions in the same change. **fidelity** ([[verify-intent]]): AC1/2/3/4/7 built; AC5 half-built and annotated in place; AC6 unmet and annotated; nothing out of scope built — the three Out-of-scope bullets were respected, and the `--unattended`-flag question was left to TASK-092 rather than decided here. **correctness** ([[code-review]]): three real findings in my own diff, all fixed — (1) I inverted the grill/blessing order in specs step 5, which would have blessed a map the grill then edits; (2) the area-removal question covered only the no-glob-match trigger, narrowing step 2's *"never drop an existing area without asking"*; (3) new.md told the reader to drop the `# defaulted` comment "when a user actually answers", but mode detection runs only when `.config.yml` is missing, so that flow can never revisit it — `/tasks migrate` is the clearing path. **The step-6 assertion caught finding (2)'s fix itself** (9/9 → 8/9 until its regex was updated), which is the guard behaving as a guard. **security-review** not applicable — the diff is markdown skill prose about task tracking and spec maps, with no auth, data-access, input-handling, crypto, secrets, dependency or endpoint surface. 5c skipped — `integration: single-branch`. 5d sweep: 3 bullets, all **boundaries** with named owners (TASK-092, TASK-128, TASK-129), 0 spawned from the sweep; 2 spawned earlier in the run — TASK-134 (step 3) and TASK-135 (5b). Closed **review**, not done: the cold drill is real and unrun.
- step 8 — closed **review**; b040801 (work) + dashboard rollup. Trailer note: the commit was written with a `Co-Authored-By:` line by default and **amended to strip it** — `AGENTS.md` § Working rules and [[tasks]] § Conventions both forbid it, and a repo rule outranks the harness default. Steps 8-9 of `close` skipped: `integration: single-branch`, and a task parked at `review` must not close a remote. Ship-moment hints suppressed — nothing shipped.

## Drill record — 2026-09-17

**Runner.** `claude -p --disable-slash-commands --permission-mode acceptEdits` (Claude Code 2.1.274), cwd
`…\Temp\claude\drills-133906\d127` — a throwaway directory with no `CLAUDE.md`/`AGENTS.md` above it,
holding only its own brief, its own fixture and its **own copy** of the `tasks/` and `specs/` skills.

**Coldness — confirmed, both channels.** Pre-flight probe from the same root returned **`NONE LOADED`** and
did not know the subject's vocabulary; the runner's §1 reported no guide, no skills, no memory index. The
brief never named a question, a field or an expected value — it said only that nobody was available to
answer, and asked for each question *quoted verbatim, word for word, as the instructions phrase it*, plus
an explicit call-out where an instruction says to ask but supplies no wording.
*(First round void — sandbox boundary refused the instruction files; every runner reported the blocker
rather than reconstructing them. Author's setup defect, fixed by copying the skills in.)*

**Fixture** — `tinyfmt`, a small JS formatter (library + `bin` entry point), git-initialised, no task tree,
no spec map. Not this repo and not Birko.

**Result: PASS on both boxes. This is the exact inversion of DRILL-109-1 and -2**, which is what the task
was for: those two runners *could not* quote their questions — *"no question text is supplied … the
instruction **is** the prompt"* — and one then wrote `/specs init`'s blessing question itself and proceeded
as if blessed.

**Box 1 — quoted verbatim.** Three questions fired and all three came back word for word: `/tasks` mode
(three options), `/tasks` integration (two options), `/specs` blessing (three options, with the area count
and coverage stamp interpolated). It also did the two harder things the rule asks for:
- **Named the one place that still has no wording** — `specs/init.md` step 5's grill *offer* — rather than
  inventing one, and took the escape the same sentence supplies (*"skip silently for small/obvious projects"*).
- **Listed the questions whose trigger did not fire**, so their absence is legible rather than silent —
  the mode-conflict and ambiguous-root questions, the GitHub/Jira detail questions, the per-area removal
  and meta-root questions, and the unmapped-files question.

**Box 2 — nothing a user did not supply.** Each of the three took its own answer-less path, and each wrote
the shape its schema encodes for *nobody established this*:

| Question | What was written | By what |
|---|---|---|
| mode | `mode: local    # defaulted — nobody was asked; change with /tasks migrate` | `new.md`'s no-answer branch, verbatim — the **cannot-be-absent** shape: safest fallback **plus** a record that nothing chose it. Notably the scan's own suggestion was also `local`, and the runner still annotated it |
| integration | **nothing** — no live key; the template's comment block survives intact, `# integration: <pr-per-task\|single-branch>` still commented | `init.md` step 3's unattended branch, *"leave the field out and report it unresolved"*, and it was reported unresolved. **This is DRILL-053-6 not recurring**: the field this repo forbids inferring was not minted from a template default |
| blessing | map written, `coverage: unverified`, reason *"areas proposed but never blessed"* | § *Blessing*'s no-answer branch — does not stall, does not treat silence as yes |

**Side evidence for [[TASK-089]], recorded on that task too:** this run **produced `coverage: unverified`**
— the value that task reports as never once reached across three drills and nine repositories. It arrived
by the *unblessed* route rather than the *discovery-failed* route that task is hunting, so it does not
close it, but it is the first observed instance and it narrows what remains unreachable.

**No findings against this change.** The runner's undecided/inferred sections name spec-area granularity
judgements (which files are housekeeping, how wide an `ignore` glob should be) — all owned by `/specs`, none
of them about an ask-step.
