---
id: TASK-034
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: [VC-020-1]
pr: null
github-issue: null
jira-key: null
---

# `tasks/README.md` holds narrative its own template cannot regenerate

## Context

Raised as a 🛑 blocker by `/verify-conventions` at TASK-020's close (2026-08-19), against
`AGENTS.md § Conventions › Working rules`: *"Generated files are owned by their verbs — never
hand-edit them … `tasks/README.md` by `/tasks triage`."*

This repo's `tasks/README.md` carries content `triage`'s template has no slot for:

- an **"In review"** section that, while verification debt was zero, explained *why the zero is
  trustworthy* — naming TASK-004 (closed on Presenter's evidence rather than the Symbio/WorkoutTracker
  drill its plan named) and TASK-018 (whose deliverable changed while it stayed `done`);
- a closing paragraph attributing each batch of closures to the round that produced it.

Neither is derivable from frontmatter, so a faithful `triage` render **deletes both**. That forces a
choice on every run: destroy the narrative, or hand-edit and diverge from the generator. TASK-020's
close took the second option — counts, priority line, in-progress section and one tree marker updated
by targeted edit — which is the violation this task owns. The reason was sound and stated at the time;
it does not make the edit compliant, and "the closer judged it fine" is not a mechanism.

The convention is not wrong. What is missing is a place for durable commentary that survives
regeneration. Note the same shape will hit `/feature status`'s generated files the moment anyone wants
to explain a phase rather than just state it — so the fix should not be README-only if that is cheap
to avoid.

## Acceptance criteria

- [ ] `triage` can regenerate `tasks/README.md` **without destroying** commentary a human wrote, or the commentary provably belongs somewhere else and is moved there
- [ ] Whichever way it resolves, running `triage` on this repo is lossless — the TASK-004 and TASK-018 caveats survive a render, or live somewhere `triage` never overwrites
- [ ] The mechanism is stated in `AGENTS.md § Conventions` if it is a new pattern (register-on-introduce), not left as tribal knowledge in one skill
- [ ] This repo's `tasks/README.md` is brought back to a state a plain `triage` run reproduces exactly — verified by running it and diffing, not by eye
- [ ] Whether `/feature status`'s generated files need the same slot is answered, either by extending the fix or by recording why they differ
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The content of the TASK-004 / TASK-018 caveats. They are accurate; this is about where they can live.
- Relaxing the never-hand-edit rule. The rule stays; the generator gains a slot, or the content moves.
- TASK-001's dependency-edge work on `STORY.md` — unrelated shape, different file.

## Human test plan

- [ ] Run `/tasks triage` on this repo and confirm the output is byte-identical to the committed file (the real test that hand-edits are gone)
- [ ] Confirm the TASK-004 / TASK-018 caveats are still readable by someone who only opens `tasks/`
