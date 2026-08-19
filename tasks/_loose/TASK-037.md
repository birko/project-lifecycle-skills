---
id: TASK-037
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Nothing detects a `skills-pi/` stub shadowing a real built-in

## Context

Named as a spawn candidate in TASK-016's implementation plan and filed by its `close` step 5d sweep
(2026-08-19), rather than folded into that task.

`pi-install.ps1`'s own header states the hazard outright:

> `skills-pi/` must NEVER be linked into `~/.claude/skills`: there the real built-ins exist and the
> stubs would shadow them.

TASK-016 added check 4, which detects a **missing** junction and a **stale** one. Neither covers this:
a junction named `code-review` in the Claude root, pointing at `skills-pi/code-review`, has a source
folder that exists, so it is not stale — and it is not missing from anywhere. Check 4 reports it as
perfectly healthy. Its `skills-pi` half is deliberately never compared against the Claude root
(TASK-016's criterion 4 requires that), so the check is structurally blind here by design.

The consequence is the worst kind: the merge gate still *runs*, but `/code-review` resolves to a
fallback stub instead of Claude Code's real pass, and every review from then on is weaker with no
signal at all. Nothing errors, and the output still looks like a review.

**Not currently present** — checked both roots at TASK-016's close: the four links in the Claude root
that point outside this repo all resolve into `Birko.Framework`, and no `skills-pi` source appears in
that root. So this is latent, like TASK-016's rename case was.

The installers cannot be the detector, for TASK-016's reason: the drift they must catch is the one
that happens when they are *not* run. This belongs as a third condition in check 4.

## Acceptance criteria

- [ ] A junction in the Claude root whose target resolves into `skills-pi/` is reported, naming the skill and why it matters (it shadows a real built-in)
- [ ] It stays advisory — same reasoning as check 4: the remedy is removing a link outside the repo, which no diff can do
- [ ] TASK-016's criterion 4 still holds: `skills-pi/` **absent** from the Claude root is still never reported
- [ ] The reverse is not invented as a defect — `skills/` linked into the pi root is correct and must stay unreported
- [ ] `skills-lint-test.sh` gains a case that fails without the new condition, non-vacuous (it must require check 4 to have run, per the guard TASK-016 added)
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Removing the offending junction automatically. Detect-and-report, for the same reason TASK-016 declined to auto-create: silently mutating a directory outside the repo needs its own agreement.
- Whether `skills-pi/` should exist at all. It is frozen and deliberate; see `docs/architecture.md` § The three trees.

## Human test plan

- [ ] Junction a `skills-pi/` skill into a simulated Claude root and confirm it is reported by name
- [ ] Confirm a clean pair of roots stays quiet
- [ ] Confirm `skills/` linked into the pi root is still never reported
