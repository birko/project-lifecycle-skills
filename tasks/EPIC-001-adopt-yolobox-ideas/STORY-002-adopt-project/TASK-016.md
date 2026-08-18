---
id: TASK-016
parent: STORY-002
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The installers only ever add — nothing detects a missing or stale junction

## Context

Spawned from TASK-011's `## Out of scope` at its close. **This is one task covering two symptoms of
the same root cause**, deliberately grouped: splitting them buries the connection that makes them
cheap to fix together.

Both installers enumerate `skills/` (plus `skills-pi/` for pi) with `Get-ChildItem -Directory` and
create one junction per folder. That loop only ever **adds**. It never compares the install roots
back against the repo, so two drifts are invisible:

| Drift | What happens | Observed? |
|---|---|---|
| **Folder added, installers not re-run** | No junction, skill resolves nowhere, its trigger phrases reach nothing | **Yes** — TASK-011: `adopt-project` shipped in `ef22e64`/`7375162` and sat unlinked in both runtimes |
| **Folder renamed or deleted** | Old junction stays behind, pointing at a path that no longer exists | Not yet — scanned both roots at TASK-011's close, zero stale, zero dangling. **Latent, not active** |

TASK-011 fixed the first instance and recorded the rule in `AGENTS.md` § Architecture / § Commands
and `docs/architecture.md`, so the next occurrence is a five-second diagnosis instead of a puzzling
"why doesn't my skill trigger". But a documented rule is a prompt to a human who remembers to read
it. Nothing *detects* either drift, and the failure is silent in both directions — which is the
same reason `skills-lint.sh` exists rather than trusting people to resolve `[[links]]` by eye.

The natural home is the existing lint: it already walks `skills/` and `skills-pi/`, so the
comparison costs one extra pass. But CI runs on Linux where `$HOME/.claude/skills` does not exist,
so an install-root check cannot be a CI gate — it is only meaningful locally. That tension is the
real design question this task has to answer, and it is why TASK-011 fenced it off rather than
folding it in: it is a design change, not a fix.

## Acceptance criteria

- [ ] Running the check on a repo whose `skills/` gained a folder since the last install reports the missing junction, naming the folder and both roots
- [ ] It reports a junction in either install root that points into this repo but has no matching source folder (the rename/delete case)
- [ ] It does **not** fail or warn on a machine where an install root is simply absent — a pi-less or Claude-Code-less machine is a normal configuration, not drift
- [ ] It does not flag the deliberate asymmetry: `skills-pi/` is linked into `~/.pi/agent/skills` only, and its absence from `~/.claude/skills` is correct, not a gap
- [ ] The decision on where it runs (installer self-check / local-only lint step / separate script) is recorded with its reasoning — an ADR if it turns out to be hard to reverse
- [ ] `.github/workflows/skills-lint-test.sh` gains a case that fails without the new check, if the check lands in the lint (the repo's rule: a change to `skills-lint.sh` is not done until a case here fails without it)

## Out of scope

- Auto-creating the missing junctions. Detect-and-report first; a check that silently mutates two directories outside the repo is a bigger decision and would need its own agreement.
- The `.sh` installers' behaviour on Linux/macOS beyond what the check needs to read. TASK-011 could not test that path either — work here is on Windows.

## Human test plan

- [ ] Add a throwaway folder under `skills/`, run the check without installing, confirm it reports the missing junction in both roots — then delete it and confirm the check goes quiet
- [ ] Rename an installed skill folder, run the check, confirm it reports the now-stale junction by name
- [ ] Run it on a machine (or a simulated `$HOME`) with no `~/.pi` at all and confirm it stays silent rather than reporting every skill as missing

## Implementation plan

_Populated by `/tasks plan TASK-016`._
