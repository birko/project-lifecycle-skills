---
name: security-review
description: Review the current diff or PR range for security concerns — auth bypasses, injection, data exposure, secret leakage, risky dependencies. Use when the user says "/security-review", "security review", when [[tasks]] close (step 5b) hits a security-touching diff (auth/session, data access, user input, crypto, secrets/config, new dependencies, exposed endpoints), or when [[feature]] review runs the optional cumulative pass on a security-sensitive feature. This is the security half of the review gate — pair with [[code-review]] (correctness) and [[verify-conventions]] (adherence).
---

# security-review

> **Pi-only stub.** Claude Code ships a native `security-review` skill; this stub exists so
> runtimes without it (pi) resolve the reference instead of silently skipping the pass.
> Never install this into `~/.claude/skills` — it would shadow the built-in.

## When this fires

- **Per-task, at `/tasks close` step 5b** — *conditionally*: the merge gate runs this when the
  task's diff touches a security surface (list in step 2). Most tasks don't; the ones that do
  must not reach `done` on a correctness pass alone.
- **Per-feature, at `/feature review` Gate A** — optional cumulative-diff pass for a large or
  cross-cutting security-sensitive feature, catching what per-task passes can't see across seams.
- **On demand** — `/security-review`, any time.

## Steps

1. **Determine the diff** (same resolution as [[code-review]]: staged → working tree →
   branch/PR range).
2. **Identify security-relevant changes:** auth/session flows, data queries, user-input
   handling, file/path handling, crypto, secrets/config, new dependencies, exposed
   endpoints or headers. **Nothing security-relevant in the diff → say so and stop** — a clean
   "no security surface in this change" is the honest result, not a reason to invent findings.
3. **Check the applicable basics** (stack-appropriate, OWASP-Top-10-shaped): injection
   (SQL/command/template), broken auth or missing authorization checks, sensitive-data
   exposure (logs, responses, error messages), SSRF/unvalidated redirects, insecure
   deserialization, secrets committed or logged, over-permissive CORS/permissions.
4. **Verify exploitability before reporting** — name the concrete attack path
   (who sends what, from where, and what they gain). Theoretical-only concerns are 💡.
5. **Report** grouped by severity, each with a clickable `path:line` **and the attack path**:
   - 🛑 **Blocker** — exploitable; must not merge
   - ⚠ **Warning** — real weakness, not directly exploitable here; fix or record why it's accepted
   - 💡 **Suggestion** — hardening / defence-in-depth
   If clean: `✅ No security issues found.`

## Args

- `--comment` — post findings as inline PR comments (`gh pr review`) instead of stdout.
- **No `--fix`.** Unlike [[code-review]], this skill never edits — see the routing rule below.
  A security fix is tracked work, not a side effect of the pass that found it.

## Conventions

- Stack-agnostic — apply the principle, not a framework-specific checklist.
- A new dependency with broad access (network, fs, child processes) is at least a ⚠.
- **Findings route into the tracker, never a silent fix.** Which lane depends on scope:
  - **In scope** for the task being closed → fix on that task's branch before it merges; the
    blocker holds the close.
  - **Outside its acceptance criteria** (a pre-existing weakness the diff merely revealed) →
    `/tasks spawn` ([[tasks]]), so it lands as its own task under the right parent instead of
    silently widening the one in hand or evaporating in chat.
  - Found at `/feature review` → a new or reopened task; the feature holds at `review` until it
    merges (never a fix inside the review step).
  - **A whole pass at project/module scale** (an audit, not a task's diff) → `/tasks intake`
    ([[tasks]]) — one EPIC (`kind: review-intake`), STORYs by severity theme, one TASK per fix
    group, with `SEC-*` ids on each; [[fix-next]] drains it worst-first, and its ranking puts
    authz bypass and cross-tenant leakage at the top. This is what "tracked work, not a side
    effect" means concretely: without the intake step there is no tracked work, only a report.
- **A shipped-behaviour security fix isn't `done` without a regression test** — same rule the
  [[tasks]] skill applies to field-found bugs. The exploit must not be able to recur silently.
