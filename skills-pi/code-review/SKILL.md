---
name: code-review
description: Review the current diff (working tree, staged, or a PR range) for correctness — logic bugs, unhandled edge cases, regressions, breaking changes to public interfaces. Use when the user says "/code-review", "review the diff", "review my changes", or when a review gate ([[tasks]] close step 5b, [[feature]] review Gate A) calls for a code-correctness pass. This is the correctness half of the review gate — pair with [[verify-conventions]] (adherence). Distinct from [[review]] (the PR-level diff review at merge time).
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
   interfaces, security-sensitive spots (input handling, auth, secrets), and missing tests
   for new surface.
4. **Verify before reporting** — a finding must name a concrete failure scenario
   (inputs/state → wrong outcome). If you can't construct one, it isn't a finding.
5. **Report grouped by severity**, each with a clickable `path:line`:
   - 🛑 **Blocker** — fix required before merge
   - ⚠ **Warning** — should fix; can be waived with a recorded reason
   - 💡 **Suggestion** — nice to have
   If clean: `✅ No correctness issues found.`

## Args

- `--fix` — after reporting, apply the confirmed findings to the working tree.
- `--comment` — post findings as inline PR comments (`gh pr review`) instead of stdout.

## Conventions

- Review the **diff**, not the whole file; don't re-review code already gated earlier —
  check the delta.
- Never weaken a finding to "looks fine" without having read the callers.
- "No tests for new surface" is a ⚠ Warning, not a Blocker (unless security-sensitive).
