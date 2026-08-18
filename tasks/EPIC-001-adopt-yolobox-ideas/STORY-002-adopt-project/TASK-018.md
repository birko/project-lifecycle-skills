---
id: TASK-018
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
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

- [x] `LAYER.md` § *Detect what the repo has* defines **present, uncommitted** — an artifact found on disk but not tracked by git — with git tracking named as the evidence to check
- [x] `LAYER.md` defines **missing, not offered** — actively absent, and the skill has decided not to offer it — carrying **the reason** as part of the state
- [x] Both states are defined **only** in `LAYER.md`, the shared inventory, so `new-project` inherits them and layer parity holds by construction
- [x] The survey checks git tracking for every layer artifact it reports as present, and the report **offers to land** untracked layer artifacts in the adoption commit
- [x] `SKILL.md` step 4's bucket table gains **amended**: per file, *what changed inside it* — appended section, replaced section, added lines — and that the user consented. Nothing amended is ever reported as created
- [x] A `missing, not offered` row survives a re-run as **adjudicated**, reported with its reason rather than re-offered
- [x] `LAYER.md` states once that adoption reports **presence, not currency**: stale content in a present artifact is never filled or rewritten, and at most noted as an aside in the report
- [x] Confirm `SKILL.md`'s survey step still reads as a **pointer** to `LAYER.md` — it did **not**, and one line was edited. TASK-012 left a four-word gloss of the state names in the router (“present, present-elsewhere, unknown, missing”) hedged as illustrative. The hedge kept it from being *wrong* when the list grew to six, but it is a restatement of a shared list, which § Conventions says not to keep; it is now a bare pointer. Named rather than silently fixed: it is the second time this gloss has needed touching for a reason the pointer was supposed to prevent
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Rewriting or refreshing stale content in a present artifact — ruled out above, by design.
- The skipped convention-inference round from the same drill → TASK-017.
- Multi-repo trees, where "untracked" means something else entirely → STORY-009.
- `new-project`'s CI stub, which still offers a workflow a fresh out-of-repo-dependency project cannot pass — surfaced by this task's `/verify-conventions` pass, spawned as TASK-019.

## Human test plan

- [x] Re-drilled WorkoutTracker (2026-08-18): `docs/BRIEF.md` reports plain `present` now that it is committed — the condition moved exactly as predicted — and CI reports `missing, not offered`, with the reason now **stronger** than when the rule was written: besides `$(BirkoSrc)`, its `package.json` carries `"file:../../../../../Web/Birko.Web.Testing"`, a second dependency resolving outside the repo root. Nothing was written, so no bucket could mislabel an amendment as a creation
- [x] Manufactured in a three-fixture scratch drill (2026-08-18) and it fires correctly. **Fixture A** (git work tree, half-landed layer): `docs/BRIEF.md` written and never committed reports `present, uncommitted`; `tasks/` with `README.md` committed and `.config.yml` untracked *also* reports `present, uncommitted` — and the contrast run proves why the probe was changed, since the old `git ls-files -- tasks/` returns `tasks/README.md`, i.e. "yes, tracked", which would have reported plain `present` and lost `.config.yml` silently. A present-but-git-ignored `secrets.local` correctly stays `present` with no offer, and landing the artifacts did not sweep it into the commit. **Fixture B** (same file shape, no repo at all): `git rev-parse --is-inside-work-tree` fails, so the state does not fire — the `git init` offer owns that case, as the precondition says. **Fixture C** (self-contained node repo, no out-of-repo deps, no CI): the CI row stays plain `missing` with the normal offer, so `missing, not offered` does not swallow the ordinary case. Re-probing after the landing commit returns clean, and a second pass has nothing to do — idempotence holds through the new state
- [x] flappy-dragon checked, and **the line's premise had moved**: it now *has* `.github/workflows/ci.yml`, so its CI row is `present`, not `missing` — which is itself the check passing, since `missing, not offered` did not swallow a row that should read present. The underlying question — would the ordinary case still get the offer? — is answered by its dependencies: `package.json` declares no `file:`/`link:` dependency that escapes the repo, so the isolation check passes and CI would be offered normally. Fixture C covered the same path on a repo with no CI at all
- [x] Exercised on fixture A: the thin `.gitignore` (`bin/ obj/ secrets.local`) was **appended** with the agent-state and env sections and reported under **amended** naming what changed inside it, never under created. Caveat on the strength of this evidence — it is a fixture, so it proves the bucket mechanics but not the judgement call on a real repo's README pointer; the WorkoutTracker line below is the version of this check that carries that

## Implementation plan

_Drafted in-conversation rather than by the `Plan` subagent — this session filed the task and holds
the drill evidence, and the session's harness rules out spawning agents unasked._

1. **`LAYER.md` § *Detect what the repo has* — grow the state list from four to six.** Add
   `present, uncommitted` (evidence: `git ls-files <path>` returns nothing) and
   `missing, not offered` (carries its reason). Reword the heading and its lead-in so no sentence
   counts the states — a count is the thing that goes stale next time the list grows.
2. **Tie `missing, not offered` to its one current producer** in § *CI a repo cannot pass*, so the
   state is not an abstraction waiting for a use: that section already says skip-and-explain, and
   the state is the shape of that report.
3. **One sentence on currency** in `LAYER.md`: adoption reports presence, not whether a present
   artifact's content is current. Never filled, never rewritten, at most an aside in the report.
4. **`SKILL.md` step 1** — drop the four-word state enumeration, keep the pointer. The gloss now
   names four of six, and the convention that shared lists are pointed at, not copied, is what says
   to delete it. Add untracked layer artifacts to the facts the survey collects alongside.
5. **`SKILL.md` step 3** — an `uncommitted` row is not rewritten; offer to land it in the adoption
   commit. Same shape as the existing `unknown`-is-not-filled rule, one line beside it.
6. **`SKILL.md` step 4** — bucket table gains **amended** (what changed inside the file, and that
   it was consented to) and a `present, not committed` bucket; the last bucket learns to report an
   adjudicated row with its reason so a re-run stops re-litigating it. Kill the "Four lists" count
   in the lead-in for the same reason as step 1.
7. **Verify** — `skills-lint` + `skills-lint-test`, then re-read the two files as a consumer would:
   every state defined once, in `LAYER.md`, with `SKILL.md` pointing at it.
8. Layer parity holds by construction — every state change lands in `LAYER.md`, the shared
   inventory, so `new-project` inherits it without a second copy.
