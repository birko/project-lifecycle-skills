---
name: handoff
description: Compact the current conversation into a handoff document a fresh agent can pick up, saved outside the workspace, with its path printed. Use when the user says "handoff", "hand this off", "write a handoff", "summarise this for the next session", "I'm starting a new session", "sprav handoff", "odovzdaj to ďalšej session", "zhrň to pre novú session". Distinct from [[tasks]] and [[fix-next]], whose task files and git history already carry a task's state — a handoff points at those rather than copying them.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it to the temporary directory of the user's OS, not the current workspace, as `handoff-<YYYYMMDD-HHMM>-<slug>.md`, where the slug is two to four words naming the work. **End by printing the absolute path** as `handoff saved: <path>`: the next session can only read a document someone can point it at, and the path is the one thing the user cannot reconstruct after a reset.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
