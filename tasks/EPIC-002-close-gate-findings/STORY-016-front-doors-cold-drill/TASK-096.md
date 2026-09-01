---
id: TASK-096
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-093-1, DRILL-093-2]
pr: null
github-issue: null
jira-key: null
---

# A conditional row cannot say what "here" means, or which kind of env var counts

## Context

**From the 2026-09-01 cold drills of `adopt-project` step 1 on `Latent` and `Birko.Framework`.** Grouped
because both are the same row's scope question — `.env.example`'s *"does anything **here** read runtime
config from the environment?"* — and neither is answerable from the row as written.

### DRILL-093-1 — "here" is undefined for an aggregator

`LAYER.md` § *Conditional rows* says to ask the artifact's own question and that **"any component
answering yes settles it."** That presumes the components are inside the surveyed repo. `Birko.Framework`
is an aggregator: **its root holds no source at all** — two directories, `docs/` and `tasks/` — while its
`.slnx` registers **343 projects**, every one resolving to a sibling directory outside the repo root, each
its own git repo. The runner:

> *"The components of this *solution* live in 176 sibling directories that are **separate git repos**,
> outside the adopted root. I chose to scope 'here' to the adopted repo (which contains no source at all),
> so `.env.example` and `Dockerfile` are `not applicable`. **Scoped to the whole solution the answer might
> differ** — `Birko.Communication.REST.Server`, `.AspNetCore` and `.gRPC.Server` exist, though as
> shared-project libraries rather than hosts. **Nothing in the instructions settles whether an aggregator
> surveys its aggregate.**"*

Its choice is almost certainly right — the layer is per-repo, and a survey that reached across 176 repos
would report gaps nobody adopting *this* repo can fill. But it is a choice the row does not make, and the
two readings give opposite states on two rows. Note this is **not** the same question as
§ *CI a repo cannot pass*, which already handles out-of-root paths as a **blocker**: that section decides
obtainability, this one decides whether the component even counts as evidence.

### DRILL-093-2 — build-time and runtime env vars are not distinguished

The row asks about **runtime config from the environment**. Every Birko consumer reads `BIRKO_SRC`, a
genuine, documented environment variable — consumed by MSBuild at **build** time to locate framework
source. **Three separate runners across four drills each reasoned this out from scratch** and each recorded
it as an inference rather than a reading:

> *"`BIRKO_SRC` is a **build-time** MSBuild variable in `Directory.Build.props`, not runtime config"*
> — the BardStudio run

> *"The one env var the repo documents, `BIRKO_SRC`, is a **build**-time MSBuild/esbuild path override …
> not runtime config. I record the consideration here because **the row does not distinguish build-time
> from runtime env vars in so many words**."* — the Birko.Framework run

> *"`BIRKO_SRC` is a genuine, repo-documented environment variable, but MSBuild reads it at build time and
> `.env` files are not how it reads it."* — the Latent run

Every one landed on the same answer, which is the point: **a rule three readers must each derive is a rule
that is not written down**, and the fourth reader is the one who gets it wrong. Getting it wrong produces a
`missing .env.example` on a desktop app with no runtime configuration at all — a false gap on the row whose
whole purpose is to avoid them.

## Acceptance criteria

- [ ] The conditional rows state what **"here"** scopes to, and an aggregator repo whose components live in sibling repos gets a defined answer rather than a runner's judgement
- [ ] The answer distinguishes this question from § *CI a repo cannot pass*, which already treats out-of-root paths as a blocker for a different reason
- [ ] The `.env.example` row says that **build-time** environment variables do not satisfy its condition, with `BIRKO_SRC` or an equivalent as the worked example
- [ ] A repo whose only env var is build-time surveys `.env.example` as `not applicable`, not `missing`, without the runner having to derive why
- [ ] Layer parity: the rows live in `LAYER.md`, which both front doors read
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The guide-section inventory and by-meaning matching — **TASK-093** settled those.
- `present, elsewhere` on a conditional row, and a licence file under a non-canonical name — **TASK-091**.
- Whether `Dockerfile`/`.env.example` should be layer rows at all. They are, and the conditional-row design is not reopened here.
- Making the survey cross repo boundaries. Almost certainly wrong, and if anyone wants it, it is a much larger question than this row.

## Human test plan

- [ ] Cold-drill the survey against an aggregator repo with no source of its own, expected answers withheld, and confirm the runner reaches the scope answer from the row rather than deriving it
- [ ] Confirm a repo whose only environment variable is build-time surveys `.env.example` as `not applicable` without commentary about having had to decide

## Implementation plan

_Populated by `/tasks plan TASK-096` — leave empty until then._
