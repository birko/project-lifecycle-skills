---
id: TASK-018
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The survey's state list and the report's buckets don't cover what a re-run actually hits

## Context

Found by drilling `adopt-project` on `C:\Sources\Birko\Consumers\WorkoutTracker` (Reps) on
2026-08-18, through the installed skill. The repo is already adopted, so the run exercised the
**upgrade path** — and hit three conditions that neither list has a slot for. `LAYER.md` § *Detect
what the repo has* mandates four states (TASK-012 taught the router those four); `SKILL.md` step 4
mirrors them as four report buckets.

**1. Present on disk, never committed.** `docs/BRIEF.md` had been written by an earlier adoption
pass that stopped before committing. The agent invented a fifth state, `present, untracked`.
Reported as plain `present`, the artifact is invisibly absent from history: the next clone has no
brief, and the next adoption pass writes one over it. An **interrupted pass is the most likely
reason anyone re-runs an idempotent adoption**, so this sits on the main path, not the margin.

**2. Missing, and deliberately not offered.** CI, correctly skipped per `LAYER.md` § *CI a repo
cannot pass* — `Directory.Build.props` resolves `$(BirkoSrc)` to a sibling framework tree. The
survey rendered it as `missing — and correctly so` and the report bucket as *"Still missing,
deliberately"*; both improvised. In the sanctioned lists it shares a bucket with *"you don't have
it and you should"*, so nothing records the decision and **every re-run re-litigates it.**

**3. Amended, not created.** `.gitignore` was appended to and `README.md` had its `## Status`
section replaced and a `## How we work` section appended — both landed under a heading reading
**Created**. The prose under each entry was accurate; the bucket contradicted it. On the upgrade
path amendment is the *normal* outcome — `LAYER.md` itself prescribes "append the How we work
pointer", "merge by section", "offer the ignore lines" — and a false claim about a user's own files
is the class of error this skill is most careful about everywhere else.

The three share one fix site: the shared state list in `LAYER.md` and the bucket table it feeds in
`SKILL.md` step 4. Filed as one task because two tasks would edit the same list twice, the second
rewriting the first.

A fourth observation from the same drill is deliberately handled as **scope, not a state**: the
README's `## Status` still said *"Scaffold (EPIC-001 / STORY-001)"* against a shipped
`1.0.0-beta.1`. The artifact was present in canonical form; its *content* contradicted the repo.
Adoption must not become a content audit, so the answer is a sentence ruling currency out, not a
sixth state.

## Acceptance criteria

- [ ] `LAYER.md` § *Detect what the repo has* defines **present, uncommitted** — an artifact found on disk but not tracked by git — with git tracking named as the evidence to check
- [ ] `LAYER.md` defines **missing, not offered** — actively absent, and the skill has decided not to offer it — carrying **the reason** as part of the state
- [ ] Both states are defined **only** in `LAYER.md`, the shared inventory, so `new-project` inherits them and layer parity holds by construction
- [ ] The survey checks git tracking for every layer artifact it reports as present, and the report **offers to land** untracked layer artifacts in the adoption commit
- [ ] `SKILL.md` step 4's bucket table gains **amended**: per file, *what changed inside it* — appended section, replaced section, added lines — and that the user consented. Nothing amended is ever reported as created
- [ ] A `missing, not offered` row survives a re-run as **adjudicated**, reported with its reason rather than re-offered
- [ ] `LAYER.md` states once that adoption reports **presence, not currency**: stale content in a present artifact is never filled or rewritten, and at most noted as an aside in the report
- [ ] Confirm `SKILL.md`'s survey step still reads as a **pointer** to `LAYER.md` and needs no edit as the state list grows — TASK-012 wrote it that way deliberately; if it does need one, that is a TASK-012 defect worth naming
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Rewriting or refreshing stale content in a present artifact — ruled out above, by design.
- The skipped convention-inference round from the same drill → TASK-017.
- Multi-repo trees, where "untracked" means something else entirely → STORY-009.

## Human test plan

- [ ] Re-drill the installed skill on **WorkoutTracker**: `docs/BRIEF.md` reports as present-but-uncommitted with an offer to land it; CI reports as adjudicated with the `$(BirkoSrc)` reason; nothing amended appears under created
- [ ] Manufacture the condition in a scratch clone — write a layer artifact, leave it untracked, re-survey — and confirm the new state fires rather than plain `present`
- [ ] Drill **flappy-dragon** (self-contained node): CI still reports plain `missing` **with** the normal offer. The new state must not swallow the ordinary case
- [ ] On a repo where the `.gitignore` lines are accepted, confirm the report's **amended** entry names what changed inside the file, and that the README pointer append is reported as an amendment rather than a creation

## Implementation plan

_Populated by `/tasks plan TASK-018` — leave empty until then._
