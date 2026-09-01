---
id: TASK-094
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-035-2, DRILL-035-3]
pr: null
github-issue: null
jira-key: null
---

# Two survey instructions whose literal reading diverges from their intent

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `BardStudio`.** Grouped because both are the same
failure shape — an instruction a careful reader can obey *exactly* and get the wrong behaviour — and both
are one sentence a reader meets in step 1. Splitting them would put two one-line fixes in two tasks.

### DRILL-035-2 — "stop" means two things, and one of them loses every defect

`adopt-project/SKILL.md` § 1: **"Print the survey as a table and stop."**

The runner obeyed it, then noticed it had nearly ended the run:

> *"The word 'stop' means 'before writing', not 'end the run' … Worth naming because **a literal reading of
> 'stop' would have ended this run at the table with F1–F3 listed and unfiled, which is the exact
> untracked outcome § 3b exists to prevent.**"*

It recovered only by reading two *other* passages — the following sentence (*"before a single file is
written"*) and § 1's complete-table exit test. So the sentence is rescued by context rather than by its own
wording, and the failure it invites is precisely the one § 3b calls *"the failure this section exists to
stop"*: real defects reported in prose and given no id. This drill found three in the target repo — a
mandated `Result<T>` that does not exist, a duplicated type name against that repo's own naming rule, and
a possibly stale dashboard — so the loss is measured, not hypothetical.

### DRILL-035-3 — "covered" does not say *by what*

`LAYER.md`'s `.gitignore` row: **"Present → check that `.env` / `.env.*` are covered and that agent-tool
local state is (`.claude/settings.local.json` at minimum); offer the lines if not."**

`BardStudio` ignores `.claude/settings.local.json` — but by the **user's global** git ignore file, not by
the repo's own `.gitignore`. The runner:

> *"'Covered' is not defined as *covered by this file* or *covered at all*. I chose to report it as a gap
> … because **a global ignore protects this one machine and not a clone**, so the row's purpose is unmet."*

That reading is almost certainly the intended one, and the reasoning is better than the rule. The other
reading is available and silently correct-looking: `git check-ignore` says the file is ignored, so a runner
that stops at the observable answer reports no gap and the next clone commits the file. **The row's whole
purpose is the clone**, so the ambiguity inverts it.

## Acceptance criteria

- [x] § 1's table instruction cannot be read as ending the run — the boundary it sets is stated as what it actually is (no writes before the user has seen the picture), without relying on a later sentence to rescue it
- [x] Whatever wording lands stays consistent with § 1's complete-table exit and § 3b's filing requirement rather than contradicting either
- [x] The `.gitignore` row states **by what** a path must be covered, and the answer accounts for a clone rather than the current machine
- [x] A global-gitignore hit is explicitly not sufficient, with the reason recorded so it is not re-litigated
- [x] Layer parity: the `.gitignore` change lands in `LAYER.md`, which both front doors read
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The seed section list the same drill found unreachable — **TASK-093**.
- `present, elsewhere` on conditional rows, and guides split over several files — **TASK-091**.
- Whether adoption should offer `.gitignore` lines at all. It should; this is about what counts as already covered.
- **Step 3b's probe set was considered and deliberately not filed.** The `Birko.Framework` runner noted its empty defect list came from three probes it chose itself, so the defect section is not reproducible run to run. That is judged *correct by design*: adoption reads an unfamiliar codebase, the yield is the point, and an enumerated probe list would become a checklist that stops at its own end — the opposite of what § 3b is for. Recorded here so the decision is findable rather than rediscovered.

## Human test plan

- [x] Hand the reworded table instruction to a cold reader with a repo carrying a real defect, and confirm the run reaches the filing step rather than ending at the table
- [x] On a machine whose global git ignore covers `.claude/settings.local.json`, confirm the survey still reports the repo's own `.gitignore` as gapped

## Implementation plan

_Populated by `/tasks plan TASK-094` — leave empty until then._

## Outcome

**What the fix was.** Two survey instructions a careful reader could obey exactly and get the wrong
behaviour. *"Print the survey as a table and stop"* used "stop" for a **write barrier** while reading as a
run terminator, and its only disambiguation was the following sentence — a drill runner had nearly ended a
run at the table with three real defects listed and unfiled. And the `.gitignore` row asked that `.env` and
agent-tool local state be *"covered"* without ever saying **by what**, so a global ignore that protects one
machine could satisfy a check whose entire purpose is the next clone. The table sentence is now a stated
write barrier that points at the exit conditions instead of relying on them; a new `LAYER.md`
§ *Covered means covered in the repo* defines covered, names the clone as the reason, and specifies
`git check-ignore -v` plus reading its **source**.

**The step-6 split.** Mechanical and decisive on the second half: on a real consumer repo whose own
`.gitignore` has no `.claude` line, `git check-ignore` reports the path **ignored** — so the old wording
yields *covered*, no offer, and the next clone commits it — while `git check-ignore -v` names
`~/.config/git/ignore:3` and `git ls-files .claude` is empty. Two probes, opposite answers, same repo.
The first half is prose and its split is the drill.

**Both test-plan items passed, and the second passed exactly as specified.** The cold runner used
`git check-ignore -v` on every path and read the source: `.env` matched `.gitignore:23` and was accepted;
`.claude/settings.local.json` matched the user-global file and was **rejected as not counting**, with
`git ls-files .claude` empty as confirmation. Its own words: *"user-global source, does not count"*, and it
closed with *"offer the two lines, and say nothing is currently at risk locally"* — the both-halves report
the new section asks for. On the first item it stated *"they told me to stop writing, not to stop running —
and they say so explicitly"*, then gave three independent reasons the run was unfinished, each traced to a
quoted sentence.

**Judgement calls, and the stricter option rejected.**

- **"Covered" is about which file carries the line, not whether it is committed.** My first wording said
  *"a file this repository tracks"*, which folded in the commit question and would have double-reported a
  single gap — a `.gitignore` with the right lines but never landed is `covered` **and**
  `present, uncommitted`. Caught in this change's own correctness pass, and `Latent` is a live instance
  (` M .gitignore`, its `.env` block unlanded since 2026-08-18), so the stricter reading would have
  misfired on a real repo at its next survey. The two questions now compose explicitly.
- **The table sentence points at the exit conditions rather than restating them.** Repeating them would
  have made the boundary self-contained at the cost of a second copy that goes stale — the defect one
  screen away in the same file.
- **`new-project` needs no edit, for a reason rather than by omission.** The scaffolder *writes* the
  `.gitignore` it would be asked about, so "the repo's own file" holds by construction; the rule only bites
  when surveying a file somebody else wrote.

**Correction to my own picking rationale — the drill proved it conservative, not wrong.** I ranked this
task partly on `.env` being a credential-exposure path, then at step 6 recorded that the path was *"not
demonstrated on this machine"*, since the global ignore here covers only `.claude/settings.local.json`.
**The drill demonstrated it by a different mechanism I had not probed:** the repo's own `.gitignore` lists
the bare `.env` and **not** `.env.*`, so `.env.local` and `.env.production` are `NOT IGNORED` and would be
committed. Verified by hand. That is the credential path, live, in the repo's own file and nothing to do
with global config. So the severity argument that drove the pick holds — I had simply looked for it in the
wrong place. Filed as **BardStudio TASK-028 (P1)**, latent rather than live since no `.env.*` exists today
and the LLM key persists outside the repo; the task also carries the `!.env.example` negation that becomes
mandatory in the same change, because `.env.*` matches the template and a negation before its pattern does
nothing.

**Flagged, not fixed.** The runner hit one further ambiguity: `docs/architecture.md`'s row says *"Leave it;
report if absent"* while § *Detect what the repo has* says architecture notes may live in the README, and
*"the two do not resolve each other"*. It chose `present, elsewhere` by the false-`missing`-is-dangerous
rule. Appended to **TASK-091** as a third instance rather than filed — that task already owns
`present, elsewhere` on rows whose cells do not discuss it.

## Follow-up

**2026-09-01, during TASK-096:** this change's correctness fix updated § *Covered means covered in the repo*
from *"a file this repository tracks"* to *which file carries the line*, but left the `.gitignore` **row
cell** carrying the superseded wording — so the row contradicted the section it points at, and the row is
what a survey reads first. Repaired in TASK-096's commit as a one-phrase out-of-scope fix, with the reason
recorded there. **The lesson is general enough to be worth stating:** when a fix changes a definition that
a row cell *summarises*, the summary is part of the change — a pointer that paraphrases can go stale
exactly like a copied list, and this one went stale within the same hour.

## Progress log

- step 2 — picked; **this revises the previous run's stated next pick (TASK-096)**, on key 1. I had under-weighted the `.gitignore` half: the row says check `.env` is *"covered"* without saying **by what**, so a runner that accepts a global-gitignore hit fires no offer and the repo ships with no `.env` protection of its own — a credential-exposure path on the next clone, which outranks TASK-096's wrong-survey-state on the severity ladder. The bundled *"print the table and stop"* half adds defect evaporation, this repo's most-measured process failure. Beat TASK-086 on key 3 (both halves fail silently; 086 surfaces a refusable offer) and key 4 (086 still has four undecided design candidates). Key 6 inert — `correctness-invariants` throughout.
- step 3 — verified: both halves held. Half 1: `adopt-project/SKILL.md:95` reads *"Print the survey as a table and stop."* and its only disambiguation is the **next** sentence; the two signals that the run continues sit at `:100` and `:106-107`, both phrased about a *complete* table, so a reader who takes "stop" literally at `:95` never reaches them. Half 2: `grep` for `check-ignore`, `covered by`, `global gitignore`, `core.excludesfile` across `LAYER.md` and `adopt-project/SKILL.md` returns **zero** — "covered" is nowhere defined.
- step 4 — layer: local.
- step 5 — fix in `skills/adopt-project/SKILL.md` (the table sentence is now a stated **write barrier**, self-contained, pointing at the exit conditions rather than restating them) and `skills/new-project/LAYER.md` (`.gitignore` row points at a new § *Covered means covered in the repo*, which defines covered, names the clone as the reason, and specifies `git check-ignore -v` plus reading its **source**). `AGENTS.md` § Conventions gains the register-on-introduce entry — see step 5b. `skills-lint` OK (18 skills).
- step 5b — **register-on-introduce: entry owed and added.** Half 2 generalises past its row: *a repo-level check is answered by what the repo tracks, never by the machine it runs on*. Two live instances (this row; TASK-096, filed, asking what "here" scopes to for an aggregator) and one apparent counter-example that actually confirms it — `skills-lint.sh` check 5 reads machine state and is **advisory for exactly that reason**, so machine state may be *reported* and never converted into a repo verdict. Recorded as a pointer to `LAYER.md`'s new section, not a second copy.
- step 6 — reverted fix: **half 2 has a mechanical split and it is decisive.** Measured on `BardStudio`, whose own `.gitignore` contains **no `.claude` line at all**: the naive probe `git check-ignore .claude/settings.local.json` reports it **ignored** — so a runner following the old wording reports *covered*, fires no offer, and the next clone commits the file. `git check-ignore -v` on the same path returns `"C:\Users\FinStat/.config/git/ignore":3` — the **user's global** file — and `git ls-files .claude` is empty. The two probes give **opposite answers on a real repo**, and only the `-v` source distinguishes them. That is the guard, demonstrated failing without it. **Honest correction to my own picking rationale:** I ranked this task partly on `.env` being a credential-exposure path. That path is structurally real — the row asks about `.env` and agent state with the same undefined word — but it is **not demonstrated on this machine**: the global ignore here covers only `.claude/settings.local.json`, not `.env`. The measured instance is therefore the lower-severity agent-state one, and the pick's severity argument is sound in structure and unproven in degree. Recorded rather than left to imply a leak I did not observe. **Half 1 is prose with no mechanical guard**; its split is the drill in the test plan. **Contract pins, not evidence:** `skills-lint` and `skills-lint-test` — neither can observe either half.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` still carries `areas: []`, so no usable spec map; `/specs init` is TASK-079. Requirements changed: none.
- step 8a — drill launched for both test-plan items, on `BardStudio`, whose divergence I verified directly (own `.gitignore` has no `.claude` line; naive probe says ignored; `-v` names the user's global file). **Fixture note on contamination:** that repo *is* named in TASK-093's § *Matching a guide's sections* with its `## Commands` answer — but contamination is **per question, not per repo**, and this task's question is the `.gitignore` row, which the new § *Covered means covered in the repo* deliberately describes as *"a real consumer repo"* without naming it. The guide row of that runner's report is therefore discounted; the ignore row is clean. Brief withholds the words *covered*, *gitignore*, *stop* and any mention of `check-ignore`, asking instead for the exact command and output behind every row that checks something is protected, and — neutrally, presupposing neither answer — *"where the instructions told you to stop, and what, if anything, they say follows"*.
- step 8b — three-axis gate, run while the drill worked. **standards ([[verify-conventions]]) — pass.** Rulebook `AGENTS.md § Conventions` via the bridge, rung 1; 3 files, 0 excluded. Both new rules are **pointers, not copies** — the `AGENTS.md` entry points at `LAYER.md`'s section, the `.gitignore` row points at it too. Layer parity: `LAYER.md` is the shared file, and **`new-project` needs no edit for a considered reason** — the scaffolder *writes* the `.gitignore` it would be asked about, so "the repo's own file" is true by construction there; the rule only bites on a survey of a file somebody else wrote. **fidelity ([[verify-intent]]) — pass**, all six criteria built; scope beyond them is the `AGENTS.md` entry, which register-on-introduce requires. **correctness ([[code-review]]) — one real finding, fixed inline:** my first wording said covered means *"a file this repository tracks"*, which silently folded in the **commit** question and would have double-reported a single gap — a `.gitignore` carrying the right lines but never landed is `covered` **and** `present, uncommitted`, and the old wording would have told the developer their lines were wrong when what was missing was the commit. **`Latent` is a live instance** of exactly that shape (` M .gitignore`, the `.env` block uncommitted from its 2026-08-18 pass), so this would have misfired on a real repo on its next survey. Now stated as *which file carries the line* — the repo's own or the machine's — with the two questions explicitly composing per § *Detect what the repo has*'s orthogonality rule. **[[security-review]] — not applicable:** three markdown files; no auth, data access, input handling, crypto or dependency surface. The `.env` subject matter is *about* secret hygiene but the diff introduces no secret-handling code. 5c skipped — `integration: single-branch`. `skills-lint` OK (18 skills); `skills-lint-test` 43/43.
- step 8c — drills passed; `review` never needed: both test-plan items were run before the status flip this time. `in-progress` → `done`. One correctness finding fixed inline (covered-vs-committed), one severity note corrected against evidence, one repo defect filed (BardStudio TASK-028, P1), one ambiguity appended to TASK-091.
