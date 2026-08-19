---
id: TASK-019
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# new-project still offers a CI stub a fresh consumer cannot pass

## Context

Spawned from TASK-018's close gate: `/verify-conventions` on that diff flagged a **layer-parity
gap that predates it**, so it does not belong in that task.

`LAYER.md`'s CI row carries TASK-007's rule — never offer CI to a repo whose build depends on paths
outside itself, because a permanently-red gate is worse than no gate. `new-project`'s own § step-5
**CI stub** bullet carries no such caveat: *"write a minimal `.github/workflows/ci.yml` … that runs
install → build → test"*, keyed only on whether the chosen stack has a known CI shape.

That is exactly backwards for the shape this team scaffolds most. `birko-new-project` hands off to
[[new-project]] for the universal layer and then wires the consumer to framework **source** through
`$(BirkoSrc)` / `BIRKO_SRC`. So a brand-new Birko consumer is created with the red-on-first-run
workflow that TASK-007 established must never be offered — the greenfield door writing what the
brownfield door refuses to write.

Two front doors, one shared inventory, and the rule living only in the row that adoption happens to
read. It is the layer-parity failure mode described in `AGENTS.md § Conventions`, arriving through
creation detail rather than through the inventory.

**Confirmed still open, and sharpened, by TASK-031's parity inspection (2026-08-19).**
`new-project/SKILL.md:124` carries no isolation guard at all — its only conditions are "skip for
docs-only" and "ask before assuming a non-GitHub CI host" — so unlike `adopt-project` it cannot reach
the `missing, not offered` state even where the state is correct. The worked case is not hypothetical:
`birko-new-project`, chained by `new-project`, wires `$(BirkoSrc)` at a sibling framework tree, which is
the `Latent` shape `LAYER.md` § *CI a repo cannot pass* exists for — arriving on a brand-new project
rather than an adopted one.

When this lands, carry `LAYER.md`'s re-derivation framing with it (reworded by TASK-031): the isolation
check is re-read from the manifests, never a remembered verdict, and what it suppresses is the offer, not
the status line.

## Acceptance criteria

- [x] `new-project`'s CI-stub step defers to `LAYER.md`'s CI row rather than restating the offer — the isolation check is the row's rule, and the step should not carry a second, weaker copy of it
- [x] Scaffolding a project whose build will reference an out-of-repo path (the stack scaffolder wires one, or the user says the framework lives outside the repo) **skips the CI stub and says why**, matching adoption's `missing, not offered` reporting
- [x] `birko-new-project`'s handoff is checked end to end: a fresh consumer gets no `ci.yml`, with the reason stated once, not a workflow plus an apology
- [x] Whatever wording lands is checked against the layer-parity rule: if it is a *rule*, it lives in `LAYER.md`; if it is *creation detail*, it lives in the step — and nothing lives in both
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Making Birko consumers CI-able at all — a distribution decision, tracked as STORY-009's territory.
- Adoption's side of the rule; TASK-007 settled it and TASK-018 gave it a state name.
- Deferred to TASK-038 — the isolation check itself **over-reports on any real .NET repo** (measured on Symbio: 318 variable-rooted hits, 99 genuine; the rest are `obj/` build output and `$(NuGetPackageRoot)`, which a runner obtains by restoring). That defect is in `LAYER.md`'s shared row, which this task only *defers* to. **P1.** This task's own guard is unaffected — its normal-case drill is a node project, and npm has no MSBuild variables — but a .NET normal case would be wrongly suppressed until TASK-038 lands.

## Human test plan

- [x] Scaffold a throwaway .NET project through `birko-new-project` and confirm no `ci.yml` is written and the reason is reported once
- [x] Scaffold a self-contained node project through `new-project` and confirm the CI stub is still written exactly as before — the caveat must not suppress the normal case
- [x] Re-read `new-project` step 5 and `LAYER.md`'s CI row back to back and confirm the rule appears in one of them, not both

## Implementation plan

### What the reading settled

**The rule already exists and is already right.** `LAYER.md`'s CI row says: *"Absent → offer a minimal
install→build→test workflow for the detected stack — **but only if the repo can build in isolation**;
see *CI a repo cannot pass* below."* Nothing needs adding to the layer. The defect is entirely in
`new-project/SKILL.md:124`, which restates the **offer** while dropping the **condition** — a second,
weaker copy of the row.

**Criterion 4's split, resolved:**

| Belongs to | What | Where it lives after this change |
|---|---|---|
| **Rule** | offer CI only if the repo builds in isolation | `LAYER.md` CI row — already there, untouched |
| **Creation detail** | the per-stack command lines (`dotnet restore/build/test`, `npm ci && …`), one job, ask before a non-GitHub host, skip docs-only | `new-project` step 5 — kept |
| **Neither, and the bug** | re-stating *"write a minimal workflow that runs install→build→test on push/PR"* | deleted from the step; that sentence **is** the row |

### The ordering fact that makes this workable

Greenfield looks like it cannot run an isolation check — a brand-new repo has no manifests to read at
intake. But step 5 invokes the **stack scaffolder first** (*"If a stack scaffolding skill was confirmed
at intake → invoke it now"*), and the CI-stub bullet comes later in the same step. By then
`Directory.Build.props` with `$(BirkoSrc)` exists. **So the check is a manifest read here too, not a
question to the user** — the same conclusion TASK-031 reached, and consistent with the convention it
added (evidence that *determines* the answer ⇒ recompute; only evidence *merely consistent with* several
answers has to be declared). Do not add an intake question for this.

### Steps

1. **`new-project/SKILL.md` step 5, CI-stub bullet** — replace the restated offer with a deference to
   `LAYER.md`'s CI row, keeping the per-stack matrix as creation detail. State the ordering explicitly:
   the isolation check runs **after** the stack scaffolder, because that is what writes the manifests it
   reads.
2. **Reporting** — when the stub is skipped, say so **once**, naming the offending dependency, matching
   adoption's `missing, not offered` line. Greenfield has no report section, so this belongs in step 6's
   finish output. A workflow-plus-an-apology is the outcome criterion 3 rules out.
3. **`birko-new-project` needs no change — confirmed by reading it.** It mentions CI nowhere; it is
   purely the wiring skill, and it explicitly leaves the universal layer to `new-project`. It also lives
   in **another repo** (`Birko.Framework`), so changing it is out of this repo's scope anyway. Criterion
   3 says *checked* end to end, and checking is what is in scope.
4. **Layer parity** — `LAYER.md` does **not** change (its rule is already correct), so parity does not
   fire. This change makes `new-project` *comply* with an existing layer rule rather than extending the
   layer. Confirm `adopt-project` still complies too, and record both rather than assuming.
5. `skills-lint` + `skills-lint-test`, then the drill.

### Risks and open questions

- **Drill item 1 is heavier than anything drilled so far, and may not be runnable.** It wants a
  throwaway .NET project scaffolded *through* `birko-new-project`. `dotnet 10.0.400` is present, but
  **`BIRKO_SRC` is unset** on this machine and the framework's `src` tree was not found at the expected
  path — which is the very condition that makes the build non-isolatable, so it does not block *judging*
  the CI decision, but it does block a real `dotnet build`. Likely resolution: drill the **decision**
  (scaffold far enough to have `Directory.Build.props` with `$(BirkoSrc)`, confirm no `ci.yml` is
  written and the reason is stated once) and record that the build itself was not run, with the reason.
  Do not claim an end-to-end .NET build that did not happen.
- **Drill item 2 is the guard and must not be skipped:** a self-contained node project must still get
  its `ci.yml` exactly as before. A caveat that suppresses the normal case is a worse defect than the
  one being fixed.
- **`new-project` is 170 lines and is a router-ish single file.** The step-5 bullet should get shorter,
  not longer — deference is fewer words than restatement. If the edit grows the file, that is a signal
  the rule is being copied again rather than referenced.

### Drill record — 2026-08-19

| Item | Result |
|---|---|
| Birko-shaped .NET project → no `ci.yml`, reason once | ✅ check returned `BLOCKED: $(BirkoSrc)\Birko.Helpers…`, no `.github/workflows` written, one finish-checklist line naming the dependency |
| Self-contained node project → stub still written | ✅ check returned `CLEAR`, `ci.yml` written with the unchanged `npm ci && build && test` shape. **The guard held** — the caveat did not suppress the normal case |
| Rule in one home, not both | ❌ **failed first, then fixed** — see below |

**Item 3 caught a real violation of criterion 4 in my own edit.** The first version of the step
re-argued `LAYER.md`'s rationale nearly verbatim (*"red on its first run and stays red … costs more than
the missing gate"*), so the *why* lived in two places. Trimmed to a pointer; verified mechanically rather
than by eye — each of *"red on its first run"*, *"teaches people to ignore"*, *"costs more than the
missing gate"* and *"build in isolation"* now appears **0× in `SKILL.md`, 1× in `LAYER.md`**.

**Two honest limits on item 1**, both foreseen in the plan and neither hidden:

- **`birko-new-project` was not executed.** It lives in another repo and needs `BIRKO_SRC`, which is
  unset here. What was drilled is the *artifact* it produces at step-5 wiring time — a
  `Directory.Build.props` defining `BirkoSrc` and a csproj importing `$(BirkoSrc)\…projitems` — which is
  the only input the CI decision reads. Criterion 3 asks for the handoff to be *checked*: done by
  reading it (it mentions CI nowhere and explicitly leaves the universal layer to `new-project`) plus
  drilling its output.
- **No `dotnet build` was run**, for the same reason. Not needed to judge the CI decision — the check is
  a manifest read — but stated rather than implied.

**Confirms TASK-038 does not affect this task**, empirically rather than by argument: the fresh scaffold
has no `obj/`, so the false `$(NuGetPackageRoot)` hits cannot arise, and item 1 was blocked by
`$(BirkoSrc)` — the right reason.

**The file grew by 4 net lines, and the plan's own risk note said growth is a copying signal.** Checked:
the growth is two genuinely new pieces of *creation detail* that `LAYER.md` does not and should not carry
— the ordering rule (run the check after the stack scaffolder, since that is what writes the manifests)
and greenfield's skip-reporting line. The rule itself shrank to a pointer. Signal considered, not ignored.

**One more duplication caught at the close gate**, one level down from criterion 4: the skip-report
format was stated in both step 5 and step 6. Step 6 owns the output line, so step 5 now points at it and
the concrete example lives once, in the owning step.
