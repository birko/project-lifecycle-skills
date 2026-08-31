---
id: TASK-082
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-066-5, CR-066-6, CR-066-7]
pr: null
github-issue: null
jira-key: null
---

# Check 4 enforces something weaker than the contract it states

## Context

**Spawned from TASK-066's close gate on 2026-08-31** (`/code-review`). Three findings, one task: all three
live in the same ~15 lines of check 4, and each is a way the check's behaviour diverges from the sentence
`AGENTS.md:190` uses to describe it — *"every `/skill verb --flag` in `skills/` must name a flag the
receiving verb declares — existence only, never semantics."*

### CR-066-5 — the match is an unanchored substring (`skills-lint.sh:131`)

`grep -qF -- "$flag" "$recv"` asks *"does this string appear anywhere in the receiving file"*, not *"is this
flag declared"*. Consequences, all silent passes:

- `--unattend` passes against a receiver declaring `--unattended` — a **truncated flag ships green**.
- `--dry` passes against a receiver declaring only `--dry-run`.
- A receiver that mentions a flag in prose **to say it is unsupported** satisfies the check.

The last one is the sharpest: the check can be satisfied by documentation that says the opposite of what the
check is asserting.

### CR-066-6 — receiver fallback is a latent false blocker (`skills-lint.sh:128-129`)

Resolution falls back to `SKILL.md` **only when the verb file does not exist**. A flag documented once on the
router — the natural home for a global flag — while `verbs/<verb>.md` exists and does not repeat it produces a
hard ERROR and fails CI for a *correct* invocation. No current call site trips it, which is exactly why it is
worth fixing now: this is the repo's only gate, and a false blocker on it is the failure that gets the gate
disabled rather than fixed.

### CR-066-7 — no `strip_noise`, no `templates/` exclusion (`skills-lint.sh:120`)

Unlike checks 2 and 3, check 4 runs over raw text. So an illustrative or negative example in a fenced block —
*"never run `/tasks close --legacy`"* — or a template teaching a **generated** project's own verb flags becomes
a hard, unsuppressable CI failure.

**The obvious fix is wrong and that is worth recording**: reusing `strip_noise` would gut the check, because
every real invocation *is* inside backticks. So the answer is an exclusion (`*/templates/*`, as checks 2–3 do)
or an opt-out marker — not the shared helper. Either way the divergence from checks 2–3 is currently
undocumented, which is how the next person "fixes the inconsistency" by adding `strip_noise` and silently
disables the check.

**Verified 2026-08-31, after I briefly got this backwards.** `strip_noise` (`skills-lint.sh:27-42`) is an awk
pass that removes fenced blocks, **followed by** `sed 's/``[^`]*``//g; s/`[^`]*`//g'` which removes inline
code spans. I first tested a hand-copied fragment containing only the awk half, concluded spans survived, and
rewrote this paragraph to say the filing was mistaken. Re-run against the real function, a sample with two
inline invocations and one fenced invocation yields **zero** surviving invocations. The filing was right:
`strip_noise` is not the answer. What *is* needed is fence-stripping without span-stripping, plus the
`templates/` exclusion.

## Acceptance criteria

- [x] The flag match is **anchored** so a prefix cannot collide — `--unattend` and `--un` must not pass against a receiver declaring `--unattended`
- [x] *Not* attempted, and recorded as such: distinguishing a **declaration** from a **mention** (a receiver saying `--legacy` is unsupported currently satisfies the check). That is semantics, which `AGENTS.md:190` scopes this check out of deliberately, and the whole-file read is a recorded choice (`skills-lint.sh:111-113`: two declaration styles are in use). Widening to semantics needs its own decision
- [ ] A flag declared on the router is found even when `verbs/<verb>.md` exists and does not repeat it - **NOT MET, deliberately.** Implemented, then reverted: consulting the router *in addition to* the verb file lets any flag named anywhere on the router satisfy any verb. Reproduced - `/tasks pick --fix` passed because `--fix` sits on the tasks router as **audit's** flag. See Outcome
- [ ] A fenced negative example and a `templates/` file cannot produce a hard CI failure - **NOT MET, deliberately.** Both halves implemented, then reverted on measurement: fence-stripping silently dropped **5 real invocations** (including the `/specs help` output block, the user-facing flag contract) and the `templates/` exclusion dropped a check on a seed that ships to consumers. See Outcome
- [x] Whatever exclusion is chosen is **documented as deliberate**, with the reason `strip_noise` is not the answer (it strips inline code spans, where every real invocation lives) - met as *no exclusion*, with the reason recorded
- [x] Each of the three has a case in `skills-lint-test.sh` that **fails without the fix** - met for the one sub-finding that proved real; the other two were rejected as non-defects, so there is nothing to pin. Two contract pins added instead (`AGENTS.md` § Testing: a change to `skills-lint.sh` is not done until a case here fails without it)
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- The stale check numbering in prose — **TASK-081**.
- Checking flag **semantics**. `AGENTS.md:190` scopes this check to existence deliberately; widening it is a different decision needing its own record.

## Human test plan

N/A — the shipped change is a lint case that fails without the fix, which is stronger evidence than a
manual read and is required by § Testing regardless; `prove the guard can fail` covers it. The two
rejected sub-findings needed measurement rather than human judgement, and their numbers are in the
Outcome. Nothing here needs a person to look at it.

*Amended at close: the original wording said "every criterion is a lint case", which was true of the
task as filed and stopped being true once two of the three sub-findings were rejected.*

## Implementation plan

_Populated by `/tasks plan TASK-082` — leave empty until then._

## Outcome

**What the fix was — and it is one third of what was filed.** Check 4 asserts that a `/skill verb --flag`
invocation names a flag the receiver declares. It did so with `grep -qF`, an unanchored fixed-string test,
so `--unattend` matched inside `--unattended` and `--dry` inside `--dry-run`: a truncated or
prefix-colliding flag shipped green on the repo's only gate. The match is now bounded on both sides by the
flag's own character class. **That is the entire code change.**

**The other two sub-findings were rejected as non-defects, after implementing both and measuring.** Both
were filed speculatively — the originating review said of one *"no current case trips it"* — and both fixes
made the gate worse. A correct "no" is a deliverable, so the evidence is recorded here rather than shipped.

| Filed | Implemented, then reverted because |
|---|---|
| **CR-066-6** — resolving the receiver to the verb file *or* the router, never both, is a false blocker for a global flag documented once on the router | Consulting both lets **any** flag named anywhere on the router satisfy **any** verb of that skill. Reproduced: appending `/tasks pick --fix` to `skills/roadmap/SKILL.md` gave `skills-lint: OK`, because `skills/tasks/SKILL.md:19` names `--fix` — as **audit's** flag. A *demonstrated* wrong-verb false negative traded for a false blocker with no instance in the tree |
| **CR-066-7** — check 4 runs over raw text, so a fenced negative example or a `templates/` file is an unsuppressable failure | Measured: fence-stripping cuts the scan from 31 invocations to 26, and **all 5 losses are genuine positive documentation** — `/specs regen --all`, `--story`, `--feature` (the fenced `/specs help` output, i.e. the user-facing flag contract), `/tasks new --from-feature`, `/tasks audit --fix`. No negative-example block exists in the tree. Separately, excluding `templates/` would stop checking `new-project/templates/CLAUDE.seed.md`'s `/tasks pick --feature` — a file that **ships to consumers**, where a renamed flag would reach every generated project |

**Step-6 split.** Lint reverted, tests kept: **42 passed, 1 failed → 43/43 with the fix.**

| Case | Without the fix | |
|---|---|---|
| flag is a prefix of a declared flag | **FAIL** — exit 0, wanted 1 | the one real defect |
| template naming a real skill is checked | passes either way | **contract pin, not evidence** |
| invocation in a non-`.md` template file | passes either way | **contract pin, not evidence** |

**The two pins exist because the rejected fixes nearly removed coverage silently.** Excluding `templates/`
and filtering the scan to `*.md` both looked like faithful tidying; neither would have failed a single
case, because no case existed. They now do.

**Judgement calls, and why the stricter option was rejected.**

- **Reverting beats shipping a fix for a hypothetical.** The tempting close was to keep all three — each
  was filed by a review, each is individually defensible, and two had passing tests. Against that: each was
  measured, and two made the only gate this repo has strictly weaker. A gate that under-enforces is the
  failure mode this whole task was about, so shipping two fresh instances of it in order to close a ticket
  about one would have been self-defeating.
- **`strip_noise` was checked twice, because I first got it wrong.** It is fence-stripping *followed by*
  `sed` that deletes inline code spans — where every real invocation lives. Mid-run I tested a hand-copied
  fragment containing only the awk half, concluded spans survived, and rewrote this task's Context to say
  the filing was mistaken. Re-run against the real function it removed **every** invocation. Moot now that
  fence-handling is rejected outright, but the correction stands on the record.
- **Declaration-versus-mention remains deliberately unattempted.** A receiver saying *"`--legacy` is not
  supported"* still satisfies the check. That is semantics, which `AGENTS.md:190` scopes out, and the
  whole-file read is itself a recorded choice: two declaration styles are in use, and keying on bullets
  alone once reported `import`'s real flags as missing.
- **Not spawned, and that is not the no-discard rule biting.** `fix-next` step 3 prescribes recording a
  rejected finding with its evidence rather than forcing it into a change; the unattended no-discard rule
  governs unowned **work** bullets, not findings adjudicated as non-defects. If either condition ever turns
  real — a genuinely global router flag, or a fenced block showing a flag *not* to use — the measurements
  above are what the next person needs, and they are here.
- **The rulebook was corrected in the same change**: `AGENTS.md:190` gains *matched **anchored*** and
  **not** the router clause I briefly added; the case count went 40 → 43.

**Flagged, not fixed:** `docs/specs/.map.yml` still `areas: []`, so step 7's respec could not run — owned by
**TASK-079**. The misplaced `Check 4 — cross-skill flags` heading in the suite is **TASK-081**'s.

## Progress log

- step 2 — picked; ranked above TASK-033 (same class: a gate that passes without checking) on key 2 reachability — check 4 runs on every CI run of the repo's only gate, while `/specs init`'s vacuous check fires only when that verb runs, and this repo has `areas: []`. Key 6 degenerate (whole pool `correctness-invariants`). TASK-086 excluded from the pool as decision-shaped.
- step 3 — verified: all three sub-findings confirmed in source and empirically (`--unattend`/`--un` pass against `--unattended`; fallback only when the verb file is absent; no strip_noise/templates exclusion at :120). RESCOPED before coding: the Context's claim that strip_noise would gut the check is false — it strips fenced blocks, not inline spans, so it is the right tool. Criterion 1 split (anchoring is in-contract; declaration-vs-mention is semantics AGENTS.md:190 excludes) and criterion 4 rewritten.
- step 3 (correction) — my rescope of the strip_noise claim was WRONG and is reverted. I tested a copy of strip_noise missing its trailing `sed` that strips inline code spans; the real function removes every invocation. Original filing restored. Criterion 1's split (anchoring vs semantics) stands — that part was independent of this error and remains verified.
- step 4 — layer: local.
- step 5 — fix in .github/workflows/skills-lint.sh (check 4 rewrite + strip_fences/strip_noise split); 6 cases in skills-lint-test.sh; AGENTS.md:190 + case count 40 -> 46. Suite 46/46, lint OK (18 skills).
- step 6 — reverted lint, kept tests: 43 passed, 3 failed. Fix-dependent = "flag is a prefix of a declared flag", "global flag declared on the router", "invocation inside a fenced block". Contract pins = the two template cases + the non-.md coverage case (pass either way).
- step 7 — respec skipped: `areas: []`. Run `/specs init` (TASK-079).
