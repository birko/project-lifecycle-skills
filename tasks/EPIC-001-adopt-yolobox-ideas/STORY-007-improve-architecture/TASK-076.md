---
id: TASK-076
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-075]
blocks: [TASK-077]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture` — the skill, its scoping pass, and the candidate filter

## Context

The core of STORY-007: **a pass whose subject is the shape of the code**, rather than a feature or a defect.
Every existing entry point is one or the other, so structural friction currently gets *noticed* and never
*addressed*.

Depends on **TASK-075**, which puts the four missing ideas into `tdd/`'s files first — this skill points at
them rather than carrying its own copies.

### What the skill has to get right

**Scope before you scan.** If the user named a direction, take it. Otherwise walk the commit history for hot
spots — the files and areas that keep coming up — and weight those first, because *deepening pays off only
where change is coming*. Scattered history with no hot spot is itself a result: widen the net rather than
picking arbitrarily.

**The finding classes** STORY-007 enumerates, each needing an observable signal rather than a definition:
understanding one concept requires bouncing between many small modules; an interface nearly as complex as
what it hides; pure functions extracted for testability while the real bugs live in *how they are called*;
tightly-coupled modules leaking across their seams; what is untestable through its current interface.

**The deletion test as the filter, not a step.** Every shallow-module candidate passes through it, and
*"merely moves it"* kills the candidate. Without that, the skill reports every small module and becomes noise
— which is the failure mode that makes an architecture review get ignored.

**Existing decision records are respected.** A candidate contradicting one is surfaced **only** when the
friction is real enough to warrant reopening it, and is **marked as such**. This matters more here than the
story's one line suggests: `docs/adr/` now holds ten records, and a refactor pass that silently proposes
undoing a recorded trade-off is how a settled decision gets re-litigated by accident.

**Naming:** `improve-architecture` is verb-noun, matching the action-skill convention.

## Acceptance criteria

- [x] The skill exists at `skills/improve-architecture/SKILL.md` with mandatory frontmatter — `name` matching the folder, and a `description` carrying the trigger phrases users actually type, including the Slovak ones
- [x] The scoping pass is **ordered**: user direction first, then commit-history hot spots, and *"scattered history, no hot spot"* is a stated outcome that widens the net rather than a dead end
- [x] Each finding class carries an **observable signal** — what you look at to decide it applies — not just a name
- [x] Every candidate states its deletion-test result (per `tdd/deep-modules.md`), and a candidate the test kills is recorded with its reason, the callers checked and the commit, so it is not raised again unless that code has changed since
- [x] A candidate contradicting a `docs/adr/` record is surfaced only on real friction, **marked as contradicting**, and names the record — never silently proposed
- [x] It points at `tdd/deep-modules.md` and `tdd/interface-design.md` via `[[tdd]]` rather than restating them
- [x] `bash .github/workflows/skills-lint.sh` passes, and the skill's `[[links]]` resolve

## Out of scope

- **The report surface** — Artifact, fallback, per-candidate shape: **TASK-077**.
- **The `/tasks intake` handoff and installer registration** — **TASK-078**.
- The four backfilled ideas — **TASK-075**, which this depends on.
- Actually running the pass on this repo. That is TASK-078's drill, once findings have somewhere to go.

## Human test plan

- [x] Run the scoping pass on this repo with **no** direction given, and confirm it either names hot spots from the commit history or says plainly that the history is scattered — not an arbitrary pick dressed as a finding
- [x] Take one candidate it surfaces and check the deletion test was actually applied, with its answer stated
- [x] Point it at an area covered by an existing ADR and confirm a contradicting candidate is marked and names the record

## Implementation plan

⚠ Acceptance criteria question — **resolved 2026-10-06 by the owner: criterion 4 reworded before work started** (the target was stale against TASK-075, not rewritten to fit a result), and the dropped-entry shape is filed as TASK-262. Original note: criterion 4 predates TASK-075's final wording of the deletion test. (a) The test judges only suspected-shallow modules, so it cannot gate classes 3–5. (b) "Merely moves" is a rejection only when the interface is not shallow; otherwise the candidate becomes a *deepen* finding, and with one caller the *Speculative generality* row decides. (c) This task has no durable record to write a rejection to: the report is TASK-077's and the intake handoff is TASK-078's. **Proposed reading, pending the owner:** every candidate states its gate result; a rejection is recorded only when the candidate is killed, in intake's `### Findings dropped at intake` list. This task *reads* that list at the start of a run and *emits* each rejection in its shape; TASK-078 *writes* it.

Drafted 2026-10-06 by the `Plan` agent. Facts checked: `docs/adr/` holds 8 live records plus `0000-retired.md` (the Context's "ten" is stale, so never hard-code a count), and `tasks/README.md` tops this repo's 6-month churn with 225 touches.

**Layout:** `skills/improve-architecture/SKILL.md` only, about 180–220 lines. It is a single-action skill, like `fix-next` and `review-comments`, so "router stays small" does not apply. TASK-077 and TASK-078 add their own sections later. No flags.

**Sections:**
1. **Opening.** The subject is the shape of the code. The output is the surviving candidates **and** everything the gate rejected, printed so the filter visibly discriminates.
2. **Step 1 — Read what is already settled.** Find earlier runs by declaration: epics with `kind: review-intake` whose `source:` names this skill. Read their dropped-findings lists and open tasks. Read the live records in `docs/adr/`; [[domain]] owns their shape.
3. **Step 2 — Scope, an ordered ladder.**
   - **Rung 1:** the user's direction, and nothing else.
   - **Rung 2:** commit-history hot spots. Window: `git log --since=6.months --no-merges --format= --name-only`; if that is fewer than 30 commits, use the whole history and say so. Keep only files `git ls-files` still lists. Drop generated and vendored files, by pointing at [[verify-conventions]]' ladder, never copying it. Drop the project's own record trees. A hot spot has at least 2× the median touch count; keep at most 5.
   - **Rung 3:** no hot spot. Report the measurement and widen the net breadth-first.

   Also computed here: co-change pairs (≥5 joint commits and ≥0.5 of the smaller file's touches) for class 4, and the files fix commits touch for class 3. Two ask-steps, each with its question and answer-less path:
   - **Direction is ambiguous:** ask which of the matches to scan. No answer → scan them all, and say so.
   - **Direction matches nothing:** ask for a path. No answer → fall to rung 2, and say so.
4. **Step 3 — Candidates.** Five classes, each with an observable signal, pointing at the owning text in `tdd/` rather than restating it:
   - concept scatter (co-change);
   - shallow interface (the deletion test's signal, `interface-design.md` item 4);
   - tested in isolation, broken at the call (fix commits land in the callers);
   - leaky seam (co-change across a boundary; the *Feature envy*, *Message chains* and *Shotgun surgery* rows);
   - untestable through its interface (item 5).

   *Design it twice* is a pointer for drafting the proposed interface, not a class.
5. **Step 4 — The deletion test gates every shallowness candidate.** Each candidate states `Deletion test: <outcome> — callers checked: <list>`. The outcome table follows `deep-modules.md`: concentrates, deepen, rejected, a one-caller module the *Speculative generality* row decides, or a data shape. A rejection is a **derived** verdict, so it suppresses the candidate, never the check. If `git log <sha>..HEAD -- <module> <callers>` is empty, print "previously rejected, unchanged"; otherwise re-run the test. Never record the result in a code comment.
6. **Step 5 — Decision records.**
   - **Contradicts a record:** the candidate reinstates a record's rejected alternative, or undoes its decision in the named area.
   - **Real friction:** step-2 evidence (a hot spot, or fix commits) attributable to the decision. With it, mark the candidate `contradicts ADR NNNN — <title>` and recommend reopening the record through [[domain]]. Without it, list the candidate as *held by ADR NNNN*.
   - No ask here.
7. **Output.** A minimal placeholder for TASK-077 to replace: the scope header, the candidates, rejected entries in the dropped-list shape `- <path> — <reason> (callers: …; at <sha>)`, and previously-rejected-unchanged entries.
8. **What it does not do; related skills.**

**Lint risks:**
- **Check 1:** the description is on one line, about 590 characters, with no unquoted `: ` or ` #`.
- **Checks 2 and 3:** links resolve with exact case.
- **Check 6:** the lint will advise that the skill folder is not linked yet. That is expected; installation is TASK-078's.

**Human test plan:**
- **No installer re-run here.** The author's run reads the file by path, and a cold runner sees no skill anyway.
- Steps 1–3 run on this repo, the only one with `docs/adr/`.
- The cold drill runs on a guide-free repo the justification does not name (`ClientApi.CSharp`, 170 commits). For step 3, seed one `docs/adr/` record in a scratch clone, stated as written for the drill.

**Spawn candidates:**
- `intake.md` must state the entry shape of its dropped-findings list, because this skill will read it (AGENTS § *A format one skill reads is a contract*) → **filed as TASK-262**, which TASK-078 now depends on.

## Progress log

- 2026-10-06 — Picked; plan drafted by the `Plan` agent and checked (8 live records in `docs/adr/`; `tasks/README.md` tops the churn at 225). Criterion 4 reworded with the owner before work started; TASK-262 filed for intake's dropped-entry shape. `skills/improve-architecture/SKILL.md` written; lint OK (20 skills). The install-root advisory "not linked" is expected and owned by TASK-078.
- 2026-10-06 — **Human test plan, step 1 (author run on this repo, no direction):** 346 commits in the 6-month window, 88 files, median 5. Hot spots: `skills/tasks/SKILL.md`, `skills/new-project/LAYER.md`, `skills/tasks/verbs/close.md`, the lint script, `skills/adopt-project/SKILL.md`. Not an arbitrary pick. **It exposed a filter gap, fixed:** `AGENTS.md` topped the list at 72 touches, so the agent guide is now dropped with the other project records.
- 2026-10-06 — **Human test plan, steps 2–3: one cold drill.**
  - **Runner:** `claude -p --disable-slash-commands --allowedTools "Bash(git:*)" "Bash(sort:*)" … < brief`, run in a scratch clone of `C:/Source/ClientApi.CSharp` (`%TEMP%/d076`). That repo has no agent guide and is not named in this skill's justification. **Coldness:** asked first to list its skills, it answered "none".
  - **Brief:** the procedure plus the passages it links to, invocation with no direction, no expected answer. The clone gained one seeded `docs/adr/0001` record (one client class per API area; it rejects merging them), stated in the record as written for the drill.
  - **Step 2:** the deletion test was applied with its answer stated. `CommonAbstractClient` (one subclass, forwarding constructors, a duplicated default URL) **concentrates** → merge. `BaseApiClient` **merely moves** with a non-shallow interface → rejected, with callers and commit. The view-model DTOs → data shape.
  - **Step 3:** "merge the diff clients" came out **held by ADR 0001**, naming the record. Candidate 1 states why it does not contradict the record.
  - **Its guesses, five fixed:**
    - a degenerate hot-spot bar (median 1, so 66 files cleared it) is now reported as degenerate, and the top five are used;
    - the directory roll-up is specified;
    - a base class with one subclass counts as one adapter;
    - the friction check now applies to a move a record blocked before it became a candidate;
    - smells outside the five classes are left out, pointing at [[verify-conventions]].

    Recorded besides: until a run is filed, the report is its rejections' only copy; renamed paths are not followed, and the header says so. Held as judgement calls the reader made sensibly: counting both subclass and type-naming sites as callers, and treating separate test projects as a module boundary.
- 2026-10-06 — **Close gate (step 5b), each axis reported separately:**
  - **Standards** ([[verify-conventions]]): no blockers. Two warnings, both fixed:
    - the hard-coded list of records to drop now points at `LAYER.md`'s documentation rows and keeps its code rows;
    - `source:` as a lookup key is now a contract on the writer (TASK-262 criterion), and the skill reports an unattributed intake epic instead of skipping it.

    Note N2 is fixed too: the output gained an "Already filed" section.
  - **Fidelity** ([[verify-intent]]): all 7 criteria met. Its notes, both fixed: the Output section was not marked provisional (the report surface is TASK-077's), and the outcome table copied `deep-modules.md`'s rows without saying that file wins.
  - **Correctness** ([[code-review]] pass): 13 findings, all confirmed.
    - Fixed in the skill:
      - history measurement now runs before scoping, so every rung gets its evidence;
      - the `@%h` format keeps commit boundaries;
      - the fix-landing search is windowed and word-bounded;
      - the degenerate-bar rule is redefined;
      - the outcome table no longer overlaps;
      - one-adapter candidates go to item 4;
      - the re-check catches new callers and a rewritten history;
      - "held by ADR" is recomputed every run;
      - the record filter now skips the retirement ledger and superseded records;
      - files at the root roll up under `.`.
    - Moved to the writing side: an intake prefix row, `source:` naming the pass, and an epic for small runs (TASK-262 criteria); writing the key, the source and the rejections (TASK-078 criterion).
  - **Re-check of the rewrite:** all 13 fixed; it found 8 new defects, all fixed:
    - fix landings matched the whole message (now subject only, and a hyphen does not end a word: 75 of 346 commits match, against 175);
    - the drop list removed code rows;
    - a degenerate bar still picked a top five (now it goes to rung 3);
    - rung 1 measured inside its own path (now the measurement is whole-repo);
    - two gates could claim one candidate (now the raising signal picks exactly one);
    - Step 5's re-check froze "held by" entries;
    - a stale step cross-reference;
    - three report items had no slot in the template.

    The candidate key is now `<class number>:<path>`.
  - **Security:** not applicable, because the diff is prose with no security surface. **Comments:** not applicable, because there are no code comments in range.
  - **Out of scope (5d):** 4 boundaries (TASK-077, TASK-078, TASK-075, the first real run as TASK-078's drill), 0 spawned, 0 declined.
