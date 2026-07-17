---
name: security-review
description: Review the current diff or PR range for security concerns — auth bypasses, injection, data exposure, secret leakage, risky dependencies. Use when the user says "/security-review", "security review", or when [[feature]] review flags a security-sensitive change (anything touching auth, data access, crypto, secrets, or external inputs).
---

# security-review

> **Pi-only stub.** Claude Code ships a native `security-review` skill; this stub exists so
> runtimes without it (pi) resolve the reference instead of silently skipping the pass.
> Never install this into `~/.claude/skills` — it would shadow the built-in.

## Steps

1. **Determine the diff** (same resolution as [[code-review]]: staged → working tree →
   branch/PR range).
2. **Identify security-relevant changes:** auth/session flows, data queries, user-input
   handling, file/path handling, crypto, secrets/config, new dependencies, exposed
   endpoints or headers.
3. **Check the applicable basics** (stack-appropriate, OWASP-Top-10-shaped): injection
   (SQL/command/template), broken auth or missing authorization checks, sensitive-data
   exposure (logs, responses, error messages), SSRF/unvalidated redirects, insecure
   deserialization, secrets committed or logged, over-permissive CORS/permissions.
4. **Verify exploitability before reporting** — name the concrete attack path
   (who sends what, from where, and what they gain). Theoretical-only concerns are 💡.
5. **Report** grouped by severity (🛑 Blocker / ⚠ Warning / 💡 Suggestion) with
   `path:line` and the attack path. If clean: `✅ No security issues found.`
   With `--comment`, post as inline PR comments instead.

## Conventions

- Stack-agnostic — apply the principle, not a framework-specific checklist.
- A new dependency with broad access (network, fs, child processes) is at least a ⚠.
- Findings feed the gate that called this: route blockers back to a `/tasks` item; never
  fix silently inside the review.
