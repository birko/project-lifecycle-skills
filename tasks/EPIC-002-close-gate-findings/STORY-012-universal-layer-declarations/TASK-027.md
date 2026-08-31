---
id: TASK-027
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `present, uncommitted` is blind to work that was staged but never committed

## Context

Found by `/code-review` on TASK-026's diff (2026-08-19), in a file that diff did not touch.

`skills/new-project/LAYER.md:104` probes the state with `git status --porcelain --untracked-files=all
-- <path>` and then reads the result by naming two line shapes: `??` for untracked members and ` M`
for the tracked-but-uncommitted amendment. Porcelain output is **XY**, where X is the index and Y the
worktree, so those two shapes cover *unstaged* work only. An earlier adoption pass that wrote the
layer **and staged it** — `git add` without a commit — prints `M ` for a modified file and `A ` for a
new one, matches neither pattern, and is reported plain **present**.

That is exactly the loss this state exists to catch: the next clone does not have it and the next
pass writes over it. It is also the same class of blindness TASK-018 was reopened for — that round
fixed the untracked case and the tracked-but-*unstaged* case, and stopped one column short.

The row is consumed by [[new-project]] and [[adopt-project]] both, so a fix in `LAYER.md` satisfies
the layer-parity rule by construction — but confirm neither skill restates the line shapes locally.

**One such restatement is confirmed** (added by `/code-review` at TASK-020's close, 2026-08-19):
`skills/adopt-project/SKILL.md:55` tells step 1 to detect anything the layer owns *"sitting on disk
**untracked**"* — untracked only. `LAYER.md:104` defines the state as covering **both** halves and calls
the tracked-but-uncommitted amendment *"the more common one on the upgrade path"* (an earlier pass
appending `## Conventions` to an already-tracked guide leaves nothing untracked at all). So even once the
`M `/`A ` columns are fixed in `LAYER.md`, adoption's own step 1 still cannot produce the state for that
case and the offer to land it never fires. Fix both halves of the probe in this task, not just the
porcelain columns.

### Re-verified 2026-08-31 (`/fix-next` step 3) — holds exactly as filed, and now with measurements

Checked empirically on a scratch repo rather than reasoned about, because the claim is about `git status
--porcelain` column semantics:

| Case | Porcelain | Matches the documented `??` / ` M` shapes? |
|---|---|---|
| new file, **staged**, never committed | `A  tasks/config.yml` | **no** |
| tracked file modified, **staged** | `M  README.md` | **no** |
| staged rename | `R  tasks/config.yml -> tasks/.config.yml` | **no** |
| tracked, modified, unstaged (TASK-018's case) | ` M README.md` | yes |
| untracked | `?? docs/BRIEF.md` | yes |
| **git-ignored** | *(empty)* | n/a — and this is the load-bearing one |
| **no repo at all** | *(empty; `fatal: not a git repository` on stderr)* | n/a |

Three things this settles that the filing could only assert:

- **The rename form is real**, not a hypothetical the criteria added for safety — `R ` is as invisible as `A `.
- **The git-ignored carve-out survives a widened rule by construction.** An ignored path yields *no* output,
  so "any non-empty output ⇒ `present, uncommitted`" falls through to plain `present` with no exception
  needed. This is why criterion 1's rule is safe to widen rather than merely tidier.
- **The no-repo case cannot manufacture the state** for the same reason: the probe fails and prints nothing
  to stdout, so criterion 4 holds without a guard of its own.

**The second half is confirmed too.** `adopt-project/SKILL.md:59` tells step 1 to detect what the layer owns
*"sitting on disk **untracked**"* — untracked only — so even with `LAYER.md` fixed, adoption's own step 1
could not produce the state for the staged or amended cases and the offer would never fire.

## Acceptance criteria

- [x] The reading rule keys on **any non-empty porcelain output** for the path rather than on a list of line prefixes — a list of shapes is what went one column short twice
- [x] Staged-but-uncommitted work (`M `, `A `, and the rename/copy forms) reports `present, uncommitted` and gets the offer to land it
- [x] A deliberately git-ignored path still reports plain `present` (the existing carve-out survives)
- [x] A directory with no repo at all still routes to the `git init` offer, not to this state
- [x] Neither [[new-project]] nor [[adopt-project]] carries its own copy of the line shapes
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The other survey states' probes. If one of them reads porcelain the same way, spawn it separately.
- TASK-026's provenance work, which only surfaced this.

## Human test plan

- [x] On a scratch clone: write a layer artifact, `git add` it, do not commit — run the survey and confirm `present, uncommitted` with the land offer
- [x] Repeat with the file modified and unstaged (the case TASK-018 fixed) — confirm no regression
- [x] Repeat with the path in `.gitignore` — confirm plain `present`
- [x] Run it in a directory with no `.git` — confirm the `git init` offer, not this state

## Implementation plan

_Populated by `/tasks plan TASK-027` — leave empty until then._

## Outcome

**What the fix was.** `LAYER.md` told an agent to read `git status --porcelain` output by matching `??` and
` M`. Porcelain is two columns — index, then work tree — so those two shapes are the *unstaged* half only.
An earlier adoption pass that wrote the layer **and staged it** printed `A `, `M ` or `R `, matched neither,
and was reported plain `present` — so the offer to land never fired and the work was gone at the next clone.
The rule now keys on the probe's output as a whole rather than on a shape list, with two exclusions and one
precondition, and `adopt-project` stops carrying its own untracked-only restatement and reads the rule off
the inventory.

**Step-6 split — and the part worth reading is that my first attempt was wrong.**

| Case | Documented rule | My first fix | Shipped |
|---|---|---|---|
| new file staged `A ` | ❌ | ✅ | ✅ |
| tracked modified staged `M ` | ❌ | ✅ | ✅ |
| staged rename `R ` (dir pathspec) | ❌ | ✅ | ✅ |
| modified unstaged ` M` | ✅ | ✅ | ✅ |
| untracked `??` | ✅ | ✅ | ✅ |
| git-ignored (empty) | ✅ | ✅ | ✅ |
| no repo (empty) | ✅ | ✅ | ✅ |
| **staged deletion `D `** | ✅ | ❌ | ✅ |
| **unmerged `UU`** | ✅ | ❌ | ✅ |
| **ancestor repo `??`** | ❌ | ❌ | ✅ |
| | **6/10** | **7/10** | **10/10** |

**My first fix — "any non-empty output ⇒ this state" — scored 7/10: it fixed three cases and broke two,
for a net gain of one over the rule it replaced.** It would have reported a staged *deletion* as
`present, uncommitted`, and `adopt-project`'s rule for that state is *"landed, not rewritten … offer it in
the adoption commit"* — so adoption would have **committed the removal**, under a report line claiming to
protect an artifact the next clone would not have. It would also have offered to commit an unmerged
conflict.

**Why my own step-6 check did not catch that, which is the lesson worth keeping.** I reported 7/7 over
seven cases — and I chose the seven. A split designed by the author of the fix tests the author's model of
the problem, so it confirms rather than challenges. The three cases that broke it (`D`, `U`, ancestor repo)
came from `/code-review`, and all three were reproduced here before being acted on. The step-6 numbers
above are the re-run, not the original.

**Judgement calls, and why the stricter option was rejected.**

- **Criterion 1, met with a nuance worth stating rather than hiding.** It asks for a rule keyed on
  non-empty output *"rather than on a list of line prefixes"*. What shipped is non-empty output **less two
  named exclusions** (`D`/` D` deletions, any `U` unmerged) **and** a presence precondition. That still
  satisfies the criterion's substance — nothing enumerates which shapes *count*, which is what went one
  column short twice — but the exclusions are themselves prefix-shaped, and the direction of failure is now
  reversed: a missed exclusion makes the rule over-inclusive rather than blind. Ticked, and recorded here
  rather than by softening the criterion's wording.
- **The no-repo carve-out is checked explicitly; the git-ignored one is not.** Asymmetric on purpose. An
  ignored path genuinely yields empty output, so it needs no rule. The no-repo claim in my first draft —
  *"outside a work tree the probe fails, so it cannot manufacture this state"* — was simply **false** for a
  directory captured by an **ancestor** repo, which this skill pair explicitly handles: verified, the probe
  succeeds and prints `?? subproject/CLAUDE.md`, so adoption would have offered to land the whole layer into
  the ancestor's history. It now compares `git rev-parse --show-toplevel` against the directory being
  adopted.
- **The rename form is attributed to its pathspec.** `R  old -> new` appears when the *directory* is
  probed; the same change probed by the member's own path is an ordinary `A `. Stating it flatly as "what
  the probe prints" was misleading about which probe.
- **Rejected: narrowing the state to distinguish adoption's writes from the user's WIP.** It is the right
  question and the wrong moment — every candidate answer is a design decision with consequences past this
  row, and taking one unattended inside a close gate is the sanctioned-by-nobody decision the guardrails
  forbid. Filed as **TASK-086** with the options enumerated.

**Flagged, not fixed:** `docs/specs/.map.yml` still carries `areas: []`, so step 7's respec could not run —
owned by **TASK-079**.

## Progress log

- step 2 — picked; ranked above TASK-061 because this is the same silent-data-loss family as TASK-066 and is its *detection* half: the state that triggers the land offer is never produced for staged work, so the offer never fires. TASK-061's consequence is a recoverable omission. Key 4 agreed (concrete two-part fix vs three shapes to choose). Key 6 (theme) degenerate again — whole pool is `correctness-invariants`.
- step 3 — verified: holds as written, and sharper than filed. Measured all seven porcelain cases on a scratch repo; staged (`A `/`M `) and staged-rename (`R `) all invisible to the documented shapes; ignored and no-repo both yield empty output, so the two carve-outs survive a widened rule for free. Second half (adopt-project SKILL.md:59 says untracked-only) confirmed. No criteria needed correcting.
- step 4 — layer: local.
- step 5 — fix in skills/new-project/LAYER.md (reading rule) + skills/adopt-project/SKILL.md (pointer, no restatement).
- step 6 (first pass) — 7/7 on seven self-chosen cases. Superseded; see the re-run.
- step 5b — standards OK (1 suggestion -> TASK-085), intent OK (6/6), correctness found SIX defects in this diff: deletion/unmerged not excluded, false no-repo claim vs ancestor repo, bad section pointer, rename pathspec, `-all` flag name. All six fixed here, not spawned - they are in-scope defects in this change.
- step 6 (re-run) — documented-old 6/10, my-first-fix 7/10, shipped 10/10. Fix-dependent cases: A, B, E (staged forms), plus D/U/ancestor which my first fix regressed.
- step 5d — 2 boundaries (first one conditional: checked, no other state probes git, so not met). Spawned TASK-084, TASK-085, TASK-086.
- step 7 — respec skipped: `areas: []`. Run `/specs init` (TASK-079).
- step 6/8 — human test plan: all four steps executed with recorded output, none needing human judgement, so `done` not `review`. status -> done.
