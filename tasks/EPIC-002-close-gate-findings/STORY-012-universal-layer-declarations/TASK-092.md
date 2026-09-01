---
id: TASK-092
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-035-1, CR-035-2]
pr: null
github-issue: null
jira-key: null
---

# `/tasks init` cannot reach its own unresolved path, and cannot record a declination

## Context

**Spawned from TASK-035's close gate on 2026-09-01** (`/code-review`, step 5b). **Filed as one grouped
task, not two**, per [[tasks]] § *Group rather than fragment*: both bullets are the same underexplored
branch of `/tasks init` step 3 — *what happens when nobody answers the `integration:` question* — and
they are individually small. Splitting them would put two fixes in one paragraph of one file with
neither task able to see the other's half.

TASK-035 gave the declaration an owner and made the scaffolder ask. Both findings are about the path
taken when that ask produces nothing.

### CR-035-1 — the unattended branch is unreachable

`tasks/verbs/init.md` step 3 now defines unattended behaviour in **two** branches (the Absent branch
TASK-035 added, and the real-choice rule that predates it): *"Unattended, with no user to ask and no
arg, leave the field absent and report it unresolved."*

`init` declares no such flag. Its `## Args` list carries `mode=`, `repo=`, `project=` and
`integration=` and nothing that asserts no user is present, and neither caller supplies one —
[[new-project]] chains `/tasks init mode=… [integration=…]`, [[adopt-project]] delegates without any
attendance argument. So the branch is prose describing a state the verb cannot be told it is in, and an
agent reaching step 3 with no `integration=` has to *guess* whether it may ask.

This is the mirror of `AGENTS.md` § *A flag that declares an absent capability must define behaviour at
every point that needs it*: there the flag existed and a step was missing, here the steps exist and the
flag does not. **The gap predates TASK-035** — the pre-existing line at what was `init.md:32` already
said "unattended" with nothing declaring it — but that change made it load-bearing in a second branch,
which is why it is filed now rather than left.

Not decided here: whether `init` grows an `--unattended` flag of its own, whether attendance is
inherited from the chaining verb, or whether the branch is rewritten to not depend on attendance at all
(*"no arg and no answer ⇒ omit the field"* needs no flag, and may be the whole fix). The third is the
cheapest and should be considered first.

### CR-035-2 — "declined" and "never asked" are the same absence

TASK-035 made an **absent** `integration:` the honest state for *unresolved*, and the template now says
so in place. It gives the file no way to distinguish:

| Why the field is absent | What the next adoption run should do |
|---|---|
| nobody has ever been asked | **ask** — the state's whole purpose |
| the user was asked and had no opinion, deliberately taking the documented default | **not ask again** |

The survey probe TASK-035 added reads presence, so on the second row it reports `outstanding` and step 2
asks again — on every re-run, forever. That is the nag this repo's own rule warns about: *"A check that
nags about a recorded decision gets muted, and a muted check is worth what an unrun one is."*

**This is the same shape as TASK-086** (adoption cannot tell its own unlanded writes from the user's work
in progress): a probe that reads observable state where two situations with opposite correct responses
produce identical evidence. Worth reading that task's four rejected designs before choosing here — but
they are **not the same fix** and should not be merged, because the record that would settle this one has
somewhere obvious to live (the config file itself) and TASK-086's does not.

Not decided here: whether the declination is recorded as a commented marker in `.config.yml`, as an
explicit third value, or somewhere else entirely. A marker is the obvious move and obvious is not the
same as right — an explicit value would make every consumer's read of the field a three-way branch.

## Acceptance criteria

- [ ] `/tasks init`'s unattended branch is reachable — either a declared way to tell it so, or a rewrite that does not depend on attendance — and no branch of step 3 describes a state no caller can put it in
- [ ] A deliberate declination is distinguishable from never having been asked, and the choice of where that is recorded is reasoned, not assumed
- [ ] A re-run of `/adopt-project` on a repo whose `integration:` was deliberately declined does **not** re-ask
- [ ] A re-run on a repo that was never asked **does** ask — the fix must not buy silence by suppressing both
- [ ] Layer parity: if `LAYER.md` changes, both front doors read the outcome from it
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Who owns *discovering* an outstanding declaration — **TASK-035** settled that (the survey owns a named declaration, the owner verb owns the version).
- TASK-086's `present, uncommitted` conflation. Same defect shape, different artifact and different candidate fixes; read it, don't merge it.
- Whether `integration:` should have a default at all. It has one, it is documented, and consumers rely on it.

## Human test plan

- [ ] On a repo whose config lacks `integration:`, run the adoption survey and confirm it asks once; answer "no opinion", then re-run and confirm it does not ask again
- [ ] On a repo that was never asked, confirm the re-run still asks
- [ ] Scaffold a project declining the integration question and confirm the resulting config states the declination rather than looking un-asked

## Implementation plan

_Populated by `/tasks plan TASK-092` — leave empty until then._
