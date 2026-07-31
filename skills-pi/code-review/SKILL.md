---
name: code-review
description: Review the current diff (working tree, staged, or a PR range) for correctness — logic bugs, unhandled edge cases, regressions, breaking changes to public interfaces. Use when the user says "/code-review", "review the diff", "review my changes", or when a review gate calls for a code-correctness pass — [[tasks]] close step 5b (the per-task merge gate, where it always runs on non-trivial work) or [[feature]] review Gate A (an *optional* cumulative-diff pass for large/cross-cutting features, not a wholesale re-review). This is the correctness half of the review gate — pair with [[verify-conventions]] (adherence) and [[security-review]] (security). Distinct from [[review]] (the PR-level diff review at merge time).
---

# code-review

> **Pi-only stub.** Claude Code ships a native `code-review` skill; this stub exists so
> runtimes without it (pi) resolve the reference instead of silently skipping the gate.
> Never install this into `~/.claude/skills` — it would shadow the built-in.

## Steps

1. **Determine the diff** — prefer staged (`git diff --cached`); fall back to the working
   tree (`git diff`), or a branch/PR range if asked. Not git-tracked → ask which files.
2. **Read the changed code in context** — understand the intent from the task's acceptance
   criteria or the feature's decisions; read enough of the surrounding file and the callers
   to judge the change, not just the hunk.
3. **Check each change for:** logic errors, unhandled edge cases (null/empty/boundary/
   concurrency), regressions in behavior the callers depend on, breaking changes to public
   interfaces, and missing tests for new surface.
   - **Security surface → escalate, don't improvise.** If the diff touches auth/session, data
     access, user input, file/path handling, crypto, secrets/config, new dependencies, or
     exposed endpoints, say so and run [[security-review]] on the same diff rather than doing a
     shallow version of it here. A one-line "looks fine" on an auth change is worse than no pass.
4. **Verify before reporting** — a finding must name a concrete failure scenario
   (inputs/state → wrong outcome). If you can't construct one, it isn't a finding.
5. **Report grouped by severity**, each with a clickable `path:line`:
   - 🛑 **Blocker** — fix required before merge
   - ⚠ **Warning** — should fix; can be waived with a recorded reason
   - 💡 **Suggestion** — nice to have
   If clean: `✅ No correctness issues found.`

## Args

- `--fix` — after reporting, apply the confirmed findings to the working tree. **Only when the
  user asks directly.** At a gate invocation (`/tasks close`, `/feature review`) the routing rule
  below wins — a gate reports and routes; it doesn't silently rewrite the diff it's judging.
- `--comment` — post findings as inline PR comments (`gh pr review`) instead of stdout.

## Conventions

- Review the **diff**, not the whole file; don't re-review code already gated earlier —
  check the delta.
- Never weaken a finding to "looks fine" without having read the callers.
- "No tests for new surface" is a ⚠ Warning, not a Blocker (unless security-sensitive).
- **Findings route by scope, not by convenience:**
  - **In scope** for the task being closed → fix on its branch; a blocker holds the close.
  - **Outside its acceptance criteria** (adjacent bug, wanted refactor the diff exposed) →
    `/tasks spawn` ([[tasks]]) — its own task under the right parent. Don't fold it into the task
    in hand (that destroys its acceptance list as an independent target), don't fix it silently,
    don't drop it.
  - Found at `/feature review` → a new or reopened task; the feature holds at `review`.
