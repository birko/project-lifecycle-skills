---
name: review
description: Review a pull request's cumulative diff at the merge gate. Use when the user says "/review", "review the PR", "review PR #N", or when [[tasks]] close (the PR-per-task merge gate) calls for the PR-level pass after the working-tree [[code-review]] + [[verify-conventions]] have run. Complements the working-tree reviews rather than re-running them.
---

# review

> **Pi-only stub.** Claude Code ships a native `review` skill; this stub exists so runtimes
> without it (pi) resolve the reference instead of silently skipping the merge gate.
> Never install this into `~/.claude/skills` — it would shadow the built-in.

The PR-level diff review. [[code-review]] and [[verify-conventions]] already ran on the
working tree at `/tasks close`; this pass reviews the **cumulative PR diff** to catch what
the per-change passes can't see.

## Steps

1. **Confirm the PR** exists for this branch and its head is current (`gh pr view`,
   `gh pr status`); note the linked task's acceptance criteria.
2. **Read the full PR diff** — `gh pr diff <number>`.
3. **Check the aggregate:** do the combined changes satisfy the task's acceptance criteria?
   Any cross-commit conflicts, merge artifacts, leftover debug/scaffolding, or integration
   issues between parts that were reviewed separately?
4. **Post findings to the PR** as inline comments (`gh pr review --comment`), grouped by
   severity (🛑 Blocker / ⚠ Warning / 💡 Suggestion).
5. **Verdict:** clean → approve (merge only with the user's go-ahead). Blockers → request
   changes; don't merge.

## Conventions

- This is an aggregate pass — don't repeat per-hunk findings the working-tree review
  already made; look for what only the whole PR reveals.
- Never merge, close, or push without the user's explicit go-ahead.
