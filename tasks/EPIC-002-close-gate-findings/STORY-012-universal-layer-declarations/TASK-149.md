---
id: TASK-149
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: [TASK-138]
findings: [DRILL-138-1]
pr: null
github-issue: null
jira-key: null
---

# Row 3 has no admission test — a plausible classification is taken for a determined one

## Context

Found by TASK-138's own cold drill, 2026-09-19. **The drill failed, and not because the rule is
missing.** TASK-138's rule is present, complete and well-argued at
`skills/new-project/LAYER.md:173-195`: row 3 covers *"no component answers yes, but one or more could
not be classified"* → **`unknown`**, and the prose even warns that row 3 is *"the one every reader
reconstructs from scratch"*.

**The runner never reached row 3.** It classified all three components, landed in row 2 — *"every
component was classified and each answers no"* — and derived a settled **`not applicable`** for both
`.env.example` and `Dockerfile`. By the table's own wording that is correct behaviour. The premise was
false.

**The fixture, and what it was built to defeat.** A three-package Python workspace where *no* component
answers yes:

| Component | Intended | What the repo shows |
|---|---|---|
| `tagcli` | clear **no** | argparse, takes a path, prints, exits |
| `reportgen` | clear **no** | pure functions, no entry point, no I/O |
| `feedsync` | **undeterminable** | console-script entry point; `dispatch(channel, plan.steps)` imported from `acme_transport`, a package **absent from the repo**; the plan it loads carries an `endpoint` |

`feedsync`'s run mode cannot be settled from this repo: that `dispatch` call is equally consistent with
a batch job that returns and a queue consumer that blocks forever. The runner wrote, in
`docs/architecture.md`, *"Nothing here is deployed as a running service. **Two CLIs and a library**,
distributed as packages and invoked on demand."* It counted `feedsync` as a CLI.

**A `[project.scripts]` entry is evidence *consistent with* on-demand invocation, never evidence that
*determines* it** — daemons ship as console scripts routinely. That determines-vs-merely-consistent
test is exactly the right one and it already exists in this file, at `:241` — but it is scoped to the
**no-components** case, explaining why an empty aggregator settles rather than going `unknown`. Nothing
applies it **per component**, which is where it was needed.

**So the gap is an admission test, not a state.** Row 3 says what to do with an unclassifiable
component and says nothing about how a component earns that label. A reader who believes every
component is classified will never look at row 3, however many times the prose tells them to read it
twice.

**Worth noting because it rules out a simpler explanation:** the same run took `LICENSE` to `unknown`
correctly and asked about it. The runner can produce the state and knows when to ask; it was not being
lazy or skipping the inventory. It was confidently wrong about one component.

## Acceptance criteria

- [ ] `LAYER.md` § *Conditional rows* states, per component, what makes a classification **determined** rather than merely plausible — and says that an entry point alone does not settle run mode.
- [ ] The rule names at least one concrete signal that looks like a classification and is not, so the test has an instance rather than only a principle.
- [ ] Row 3's admission condition is reachable from the per-component step, not only from the table — a reader who thinks they are in row 2 must have something that sends them to check.
- [ ] A dependency whose implementation is **outside the repo** is named as a determinacy blocker: run mode that hinges on an absent package cannot be read off this repo.
- [ ] The existing determines-vs-consistent sentence at `:241` is reconciled, not duplicated — one statement of the test, applied in both places.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The row-3 state itself and the No-direction table — TASK-138, present and correct.
- The adopter's per-state reporting list — TASK-112 already owns `not applicable` missing from it.
- Fixing anything in the drill fixture: it is a throwaway, and the four real defects the run found in it are the fixture's own, not this repo's.

## Human test plan

- [ ] Re-run TASK-138's drill on the same fixture (kept at `scratchpad/drill-138`, resettable with `git reset --hard && git clean -fd`). Expected: `.env.example` and `Dockerfile` both reach **`unknown`**, naming `feedsync` and stating that its run mode depends on `acme_transport`, which is not in the repo. Brief must not name the ambiguous component.
- [ ] Confirm `docs/architecture.md` does **not** assert a run mode for `feedsync`. The first run's *"two CLIs and a library"* made the wrong verdict durable in an artifact, which is worse than a wrong line in a report.
- [ ] Add a fourth component that is clearly a service and re-run. Expected: both rows settle **Yes** — the fix must not turn the Yes path into `unknown`, which would be symmetry achieved by breaking the half that works.
- [ ] Confirm `LICENSE` still reaches `unknown` and is still asked. It behaved correctly in the failing run, so it is the control.
