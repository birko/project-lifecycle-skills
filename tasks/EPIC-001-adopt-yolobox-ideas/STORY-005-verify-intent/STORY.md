---
id: STORY-005
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# The merge gate's third axis — `verify-intent` and the smell baseline

## User story

As a reviewer at the merge gate, I want to know whether the diff actually built what was asked —
separately from whether it follows the rules and whether it is correct — so that clean, conventional
code implementing the wrong thing cannot pass.

## Behaviour

- **Two axes, reported side by side, never merged or reranked.** A change can follow every documented standard while implementing the wrong thing (standards pass, intent fail), or do exactly what was asked while breaking the project's conventions (intent pass, standards fail). Reranking across them lets one mask the other.
- **`verify-conventions` becomes the standards axis** and gains a **smell baseline** — a fixed set of code smells (mysterious name, duplicated code, feature envy, data clumps, primitive obsession, repeated switches, shotgun surgery, divergent change, speculative generality, message chains, middle man, refused bequest) that applies even when a repo documents nothing. Two rules bind it: **the repo overrides** — a documented standard always wins and suppresses a conflicting smell — and **every smell is a labelled judgement call**, never a hard violation. Skip anything tooling already enforces.
- **`verify-intent` is a new skill** carrying the fidelity axis, with three finding classes: requirements asked for but **missing or partial**; behaviour in the diff nobody asked for (**scope creep**); requirements that look implemented but are **wrong**. Each finding quotes the line it came from.
- It reads the task's acceptance criteria, the feature's approved decisions, and `docs/specs/` for the touched area — a better spec source than a tracker lookup, because it is in the repo.
- **Named `verify-intent`, not `verify-spec`**: `/specs verify` already means staleness, and a second "verify-spec" would collide on the same repo. "Intent" also covers all three finding classes where "scope" covers only two.
- Invoked from `tasks/close` step 5b beside `verify-conventions`, and from `/feature review` — but **runnable standalone**, because half the value is asking "does this match what was asked?" mid-work, before the gate.
- **Lands in `skills/`, not `skills-pi/`.** A two-axis rewrite of the pi-only stub would reach pi alone and leave Claude Code users on the native single-axis pass. `skills-pi/` keeps doing its one job: a plain correctness fallback where the runtime ships none.

**Independent of everything past STORY-001** — pull it forward for a short session.
