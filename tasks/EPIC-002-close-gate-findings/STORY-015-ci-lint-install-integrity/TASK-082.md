---
id: TASK-082
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
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

## Acceptance criteria

- [ ] A flag matches only where the receiver **declares** it, not merely mentions it — `--unattend` must not pass against a receiver declaring `--unattended`
- [ ] A flag declared on the router is found even when `verbs/<verb>.md` exists and does not repeat it
- [ ] A fenced negative example and a `templates/` file cannot produce a hard CI failure
- [ ] Whatever exclusion is chosen is **documented as deliberate**, with the reason `strip_noise` is not the answer
- [ ] Each of the three has a case in `skills-lint-test.sh` that **fails without the fix** (`AGENTS.md` § Testing: a change to `skills-lint.sh` is not done until a case here fails without it)
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- The stale check numbering in prose — **TASK-081**.
- Checking flag **semantics**. `AGENTS.md:190` scopes this check to existence deliberately; widening it is a different decision needing its own record.

## Human test plan

N/A — every criterion is a lint case that must fail without the fix, which is stronger evidence than a
manual read and is required by § Testing regardless. The `prove the guard can fail` step covers it.

## Implementation plan

_Populated by `/tasks plan TASK-082` — leave empty until then._
