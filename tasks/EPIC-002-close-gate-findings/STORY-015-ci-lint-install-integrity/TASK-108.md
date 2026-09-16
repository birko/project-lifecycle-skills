---
id: TASK-108
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: fix-next
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-1]
pr: null
github-issue: null
jira-key: null
---

# Check 4 only sees a flag that immediately follows the verb, so a fifth of real invocations are unchecked

## Context

**From a [[code-review]] pass on 2026-09-08**, filed via `/tasks intake` alongside CR-3 to CR-7.

`.github/workflows/skills-lint.sh:120` matches cross-skill invocations with
`/[a-z][a-z-]* [a-z][a-z-]* --[a-z-]+` — a flag **immediately** after the verb. Every invocation that
carries an argument between the two is invisible to the gate:

| Invocation | Where |
|---|---|
| `/specs regen <areas> --story` | `specs/SKILL.md:174`, `tasks/verbs/close.md:272` |
| `/tasks move <ids> --to` | `intake.md:151` — a verb added in this same epic |
| `/tasks plan {{ID}} --replan` | `plan.md` |
| `/tasks block <origin> --on` | ×2 |
| `/tasks export <ID> --to` | `export.md` |
| `/tasks new task --from-feature … --no-plan` | `intake.md` |

**8 of 39 real invocations — roughly 20% — silently unchecked.** And because `grep -o` ends each match
at the first flag, a **second** flag on the same invocation (`--no-plan` above) is never checked either,
even when the first one matched.

### Why this is worse than an ordinary gap

`AGENTS.md:216` asserts, of the flag contract, *"the lint enforces it"*. That sentence is now false for a
fifth of the cases it claims to cover, and the failure is silent in the direction that matters: rename
`--to` on `move.md` today and the gate stays green. A check believed to be enforcing is worse than a
check known to be absent — the same argument this repo already made about muted checks, arriving from
the other side.

**No test case pins the arg-then-flag form**, which is why the gap survived TASK-045 (which added the
check) and TASK-082 (which tightened it).

## Acceptance criteria

- [x] Check 4 matches an invocation with arguments between the verb and the flag, and matches **every**
      flag on one invocation rather than stopping at the first
- [x] All 8 invocations listed above are checked — verified by making one of them reference a flag the
      receiving verb does not declare and watching the lint fail
- [x] Matching stays **anchored** on the flag name, so `--unattend` still does not satisfy a receiver
      declaring `--unattended` (the property TASK-082 established — do not regress it)
- [x] `skills-lint-test.sh` gains cases that **fail without the fix**: one arg-then-flag invocation, one
      multi-flag invocation, and one negative case proving the anchoring still holds
- [x] The false claim is resolved: either `AGENTS.md:216` is true after the fix, or it is amended to say
      what is actually enforced
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- **The check-4 / check-5 numbering contradiction** — **TASK-081** owns it; CR-2 was linked there rather
  than re-filed.
- Widening check 4 to verify flag *semantics*. It checks existence only, deliberately.
- Any other lint check.

## Human test plan

- [x] Rename `--to` in `skills/tasks/verbs/move.md`'s declaration without touching the caller, and run
      the lint. Expected: it fails and names the caller. Before this fix it passes.

## Progress log

- step 2 — picked; ranked above TASK-127 because key 1 (severity): this degrades the repo's only
  automated gate, so it weakens the mechanism that would catch every other defect. Also key 3
  (silence — CI reports green while a fifth of invocations go unchecked) and key 7 (sole P1 of 34).
  Key 6 was inert: every themed candidate carries `correctness-invariants` and three carry no theme
  by construction. No branch cut — `integration: single-branch`.

- step 3 — verified: held as written. Measured 31 matched + 8 invisible = 39; the two-flag case
  (`/tasks new task --from-feature FEATURE-NNN --no-plan`) reproduced as described.
- step 4 — layer: local. `.github/workflows/skills-lint.sh` is this repo's own gate; no upstream.
- step 5 — fix in .github/workflows/skills-lint.sh (check 4 pattern + per-flag loop) and
  AGENTS.md:238 (the enforcement claim); tests in .github/workflows/skills-lint-test.sh.
- step 6 — FIRST attempt: 45/47 against the original lint. Superseded — see step 8.
- step 7 — respecced: N/A, and not a skip. Area `skill-authoring-rules` has no generated spec body
  (standing DV7); nothing documents this defect as shipped behaviour. Generation is TASK-080's.
- step 8 — close gate: standards + fidelity inline, correctness via /code-review on the two .github
  files. 9 findings, 2 major, ALL addressed — including two defects in this very fix: a bare-word
  ARG_RE that read ordinary prose as an invocation, and a prose pin that was VACUOUS (backticks made
  the argument repetition unreachable, so no widening could ever have failed it). Pattern reworked
  from "any bare word" to argument-shape; step 6 re-run from scratch afterwards.
- step 6 (re-run, final) — reverted fix: 45/47 passed, 2 failed; fix-dependent = `arg between verb
  and flag, undeclared`, `second flag on one invocation`; `prose between verb and distant flag` is a
  pin against the original baseline but real evidence for the shape rule — it fails when ARG_RE is
  loosened to `[^ ]+`, verified directly; pin = `arg between verb and flag, declared`.
- step 8b — human test plan RUN, not parked: renaming `--to`'s declaration in move.md failed the
  lint naming intake.md as the caller, exit 1; restored, lint green. Machine-checkable, so automated
  rather than accepted as manual (close step 5).

## Outcome

**What was broken.** The repo's only automated gate claimed to check that every flag one skill passes to
another is declared by the receiving verb. It only looked at flags sitting *immediately* after the verb,
and only at the *first* flag on a line. So `/tasks move <ids> --to`, `/specs regen <areas> --story`,
`/tasks plan {{ID}} --replan` and five others were never checked at all — 8 of 39 real invocations, ~20% —
and `--no-plan` in `/tasks new task --from-feature FEATURE-NNN --no-plan` was invisible even on a line the
check did match. Rename a flag on the receiving side and CI stayed green.

**The fix.** Check 4 now allows arguments between the verb and its flag, accepts `--flag=value`, and loops
over every flag on the invocation rather than stopping at the first. Flags are extracted **space-anchored**,
so an argument like `well--known` no longer yields a phantom `--known`.

**What an argument may look like is the whole design, and the first attempt got it wrong.** I initially
allowed any bare word between verb and flag and reported "zero false positives" — which was a measurement
of today's repo, not a property. The close gate's correctness axis showed it reads ordinary prose as an
invocation: `The /beta go step runs before the --nosuch cleanup.` errored, and `skills/` already carries
unbackticked `/skill verb <word>` sentences that would trip it the day one gained a flag. On a **fatal**
check that matters more than the gap being closed, because prose is not a diff anyone can fix.

So an argument is now a placeholder (`<areas>`, `{{ID}}`), an identifier or number starting upper-case or
numeric (`FEATURE-NNN`, `3`), or an ellipsis — **plus at most one lowercase word**, in the subcommand slot
(`/tasks new task …`). Prose runs several lowercase words together and therefore cannot match. The
one-lowercase-word ceiling is deliberate: `/beta go a b c d e f --x` is prose by construction, and widening
to reach it would reopen the false positive.

**Rejected: anchoring on backticks.** Tempting and precise — 35 of 39 invocations are inside a code span.
The other 4 are in fenced blocks in `help.md`, so a backtick rule would silently stop checking them, and
detecting a fence in `grep` needs the inverse of `strip_noise()`. Shape does the same job without a parser.

**Step 6 — the split, as numbers.**

```
against the ORIGINAL lint:  45 passed, 2 failed
with the fix:               47 passed, 0 failed
```

- **Fix-dependent (evidence), by name:** `arg between verb and flag, undeclared` · `second flag on one
  invocation`.
- **`prose between verb and distant flag` — evidence for the shape rule, a pin against the original.**
  It passes on the original lint (which never matched prose either), so against *that* baseline it is a
  pin. It **fails** when `ARG_RE` is loosened to `[^ ]+`, verified directly, so it does pin the thing it
  claims to. Its first version was **vacuous** — the invocation was wrapped in backticks, which made the
  argument repetition unreachable, so no widening could ever have failed it. Recorded because a negative
  assertion that cannot fire is the defect this repo already documents for the lint's advisory section.
- **Pin, not evidence:** `arg between verb and flag, declared` — the indiscriminate-guard pair.

**Additionally verified on the real repo, in both directions:**

- caller mutated — `/tasks move <ids> --to` → `--tonowhere` in `intake.md`: lint fails naming the caller,
  exit 1.
- receiver mutated (the `## Human test plan` step) — `--to`'s declaration renamed in `move.md` with the
  caller untouched: lint fails naming `intake.md`, exit 1.

Both restored; lint green. That exercises a formerly-invisible invocation end to end rather than only
through a fixture, and the plan step was **run** rather than parked, because it is machine-checkable.

**Judgement calls, and why the stricter option was rejected.**

- **Did not verify flag *semantics*** — out of scope on the task and deliberately so in `AGENTS.md`.
- **Did not touch the anchoring.** TASK-082 established that `--unattend` must not satisfy a receiver
  declaring `--unattended`; its case still passes.
- **`AGENTS.md:238` amended rather than left true-by-luck** — it asserted *"the lint enforces it"* while
  describing the narrow form. It now describes what is enforced and records that the old form left 8 of 39
  unchecked while still claiming enforcement.

**Also corrected in this change, all found by the correctness axis:**

- `AGENTS.md` recorded **43** test cases; the suite has **47**. That count is tracked *by convention* here,
  and it was stale in the same file this change was already editing.
- The comment above check 4 still measured "30 such invocations, **all** of the form `/skill verb --flag`"
  — now marked superseded rather than deleted, since it records why the check was added.
- `skills-lint-test.sh` called **check 4** advisory. Check **5** is the advisory one; on a change squarely
  about check 4 that would have sent the next reader to the wrong place.

**Flagged but not fixed.**

- **Step 7 did not apply, and this is not a skip.** The area is `skill-authoring-rules` (sources
  `skills-lint.sh`, `skills-lint-test.sh`). Its `.map.yml` entry exists but **no spec body has ever been
  generated** — the standing DV7 finding — so `docs/specs/` does not document this defect as shipped
  behaviour and there is nothing to correct. Generating it is TASK-080's, sequenced behind STORY-004,
  STORY-006 and STORY-007.
- **The check-4 / check-5 numbering contradiction is TASK-081's**, untouched, as `## Out of scope` requires.
- **A numeric-only argument now matches, a six-lowercase-word run does not.** Both are consequences of the
  shape rule and are documented in the check's own comment, so a future reader meets the reasoning rather
  than rediscovering it.
